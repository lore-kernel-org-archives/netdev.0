From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: kernel panic when running /etc/init.d/iptables restart
Date: Tue, 25 Dec 2012 13:36:03 +0800
Message-ID: <50D93B43.8060303@cn.fujitsu.com>
References: <CAFFEFTXxsPRf1Rmxyih0wL4O6q8G0OFmz0iRLX0tOYedYfajHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: canqun zhang <canqunzhang@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAFFEFTXxsPRf1Rmxyih0wL4O6q8G0OFmz0iRLX0tOYedYfajHw@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

cc netdev
Hi canqun:

On 2012/12/24 13:51, canqun zhang wrote:
> Hi Patrick=EF=BC=8C
> If i start  one lxc container instance, and then in the system there
> will be two net namespaces,one is init_net namespace, the other is
> created by lxc.If running "/etc/init.d/iptables restart",the system
> will be panic. I find iptables restarting will clean init_net
> namespace firstly,then clean the net namespace created by lxc,buf
> related functions about cleaning up init_net namespace will destroy
> global variables such as nf_ct_destroy,ip_ct_attach=EF=BC=8Cetc.So,fu=
ntions
> cleaning up  the other net namespace will be panic.
>=20

I'm afraid that the system will not panic.
When do rmmod nf_conntrack_ipv[4,6],we already call nf_ct_iterate_clean=
up
to destroy the nf_conns which belongs to l[3,4]proto  protocols,At this
time the nf_ct_destroy still points to destroy_conntrack because the mo=
dule
nf_conntrack is hold by l3 and l4proto.
You can check the function nf_conntrack_l[3,4]proto_unregister.

Can you make it a little clear?
The reproduction and oops dump stack is useful.

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
