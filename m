From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCHSET] Mobile IPv6 for 2.5.43
Date: Fri, 01 Nov 2002 12:22:12 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021101.122212.601751630.yoshfuji@linux-ipv6.org>
References: <20021031.174442.846937513.takamiya@po.ntts.co.jp>
	<Pine.GSO.4.44.0210311232310.18909-100000@morphine.tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takamiya@po.ntts.co.jp, ajtuomin@morphine.tml.hut.fi,
	davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, pekkas@netcore.fi,
	torvalds@transmeta.com, jagana@us.ibm.com, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: lpetande@morphine.tml.hut.fi
In-Reply-To: <Pine.GSO.4.44.0210311232310.18909-100000@morphine.tml.hut.fi>
List-Id: netdev.vger.kernel.org

In article <Pine.GSO.4.44.0210311232310.18909-100000@morphine.tml.hut.fi> (at Thu, 31 Oct 2002 12:44:00 +0200 (EET)), Henrik Petander <lpetande@morphine.tml.hut.fi> says:

> > (2) Avoiding Netfilter Hooks
> > 	In your imprementation HA uses netfilter to intercept packets
> > 	sent to MN. We think it is costy so we have a suggestion to
> > 	use FIB structure to forward packets to MN. Bacause we think
> > 	forwarding packets from HA to MN is FORWARDING, not FILTERING.
> > 	We think the kernel maintainers may prefer such a manner using
> > 	FIB structure for forwarding.
> 
> We are using standard routing in HA to route packets intercepted by HA to
> MN through a tunnel device.  However, HA needs to also act as a neighbor
> discovery proxy for MN and not tunnel any ND packets destined to MN, but
> reply to them on the bahalf of MN. We use the netfilter hook to check for
> ND packets with global addresses that would be otherwise tunneled and feed
> them directly to the local processing code.

I believe that netfilter is not appropriate here.
If it is protocol requirement, do it in the stack itself.

Well, HA is router. 

Sending side: Make mip6_forward().
              When new MN is being registered, setup proxy ndisc and 
              make routes to MN via mip device (which is mip tunnel),
              which actually calls mip6_foward().
              When packet arrives, it checks MNs and forward it to it.
Receiving side: 
              mipl tunnel receives packets from MN.
              check source address according to the list of MNs,
	      then forward it.

Also, I believe that the binding information should be hold as FIB entry.

--yoshfuji
