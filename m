From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] neighbour : fix ndm_type type error issue
Date: Sat, 26 Jul 2014 15:42:46 +0200
Message-ID: <1406382166.19420.145911853.784D75D0@webmail.messagingengine.com>
References: <1406306339-16151-1-git-send-email-mypopydev@gmail.com>
 <1406330697.989.145785925.1CA960AF@webmail.messagingengine.com>
 <1406334557.5276.13.camel@popy-debian>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org,
	Francesco Fusco <ffusco@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	Jiri Pirko <jiri@resnulli.us>,
	David Stevens <dlstevens@us.ibm.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	linux-kernel@vger.kernel.org
To: Jun Zhao <mypopydev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406334557.5276.13.camel@popy-debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sat, Jul 26, 2014, at 02:29, Jun Zhao wrote:
> On Sat, 2014-07-26 at 01:24 +0200, Hannes Frederic Sowa wrote:
> > On Fri, Jul 25, 2014, at 18:38, Jun Zhao wrote:
> > > ndm_type means L3 address type, in neighbour proxy and vxlan, it's
> > > RTN_UNICAST.
> > > NDA_DST is for netlink TLV type, hence it's not right value in this
> > > context.
> > 
> > The value of NDA_DST == RTN_UNICAST, otherwise we couldn't do this
> > change as it would alter e.g. arpd behavior.
> > 
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > 
> > Thanks,
> > Hannes
> 
> But I think NDA_DST/RTN_UNICAST have different means in this context, 
> even though the value of NDA_DST == RTN_UNICAST.
> 
> For arp proxy/NDP proxy context, ndm_type means the peer L3 address,
> so RTN_UNICAST is the right value. For vxlan have similar semantic for
> remote ip.
> 
> BTW: In the source code, implicit think NDA_DST == RTN_UNICAST maybe
> not a good idea when we don't have a comment or the other explain.

I am totally with you and think your change is good, that's why I also
gave my ack to your patch.

My comment above was about my concerns regarding making a user space
visible change, which in the end could alter the behavior of already
existing software.

Developers maybe have debugged code and seen some different value being
propagated from the kernel and this software could now break if we would
change the value after all those years.

Bye,
Hannes
