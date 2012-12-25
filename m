From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: kernel panic when running /etc/init.d/iptables restart
Date: Tue, 25 Dec 2012 16:50:11 +0800
Message-ID: <50D968C3.7000306@cn.fujitsu.com>
References: <CAFFEFTXxsPRf1Rmxyih0wL4O6q8G0OFmz0iRLX0tOYedYfajHw@mail.gmail.com> <50D93B43.8060303@cn.fujitsu.com> <CAFFEFTULzSysz+JCBC==VtKD8u1KO6EZnSdQ5XWM7um-zs9_pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: canqun zhang <canqunzhang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFFEFTULzSysz+JCBC==VtKD8u1KO6EZnSdQ5XWM7um-zs9_pg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012/12/25 15:25, canqun zhang wrote:
> Hi Gao feng
> The stack information is as follows. The kenel will panic because the
> nf_ct_destroy is NULL.

Thanks!
It seems that nf_conntrack_l[3,4]proto_unregister doesn't make sure
nf_conns of the proto being destroyed.

If I'm right, there is another problem even your fix this panic problem.
the l3,14proto will be unregistered before all of it's nf_conns being destroyed.
So even nf_ct_destroy is not NULL,in destroy_conntrack we are not able to
find the right l4proto,the l4proto->destroy will be incorrect.resources will
not be released correctly.

So I think the root problem is we do register/unregister, set/unset both on the
first net (init_net), Maybe it's better to do register set on the first net, and
do unregister unset on the last net.
