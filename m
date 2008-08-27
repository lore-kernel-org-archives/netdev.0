From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Thu, 28 Aug 2008 00:25:31 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0808272358230.4759@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux> <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux> <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
 <20080824163843.33b4f890@tux> <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
 <20080826141812.589848a0@tux> <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
 <20080826181731.4581fd2c@tux> <Pine.LNX.4.64.0808271236080.1034@wrl-59.cs.helsinki.fi>
 <20080827165142.4bc7b70f@tux> <Pine.LNX.4.64.0808272319520.4693@wrl-59.cs.helsinki.fi>
 <20080827175012.580efae1@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1677718646-1219872331=:4759"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51190 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbYH0VZc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 17:25:32 -0400
In-Reply-To: <20080827175012.580efae1@tux>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1677718646-1219872331=:4759
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 27 Aug 2008, Dâniel Fraga wrote:

> On Wed, 27 Aug 2008 23:32:34 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Ok. Though this all opens more questions than answers... :-(, why isn't 
> > there any traffic in neither of the tcpdumps then (not in the client's
> > nor in the server's).
> 
> 	Very strange. In this topic, I saw the discussion about some
> routers messing with traffic and frto related stuff, right? My server
> is behind some routers that I don't know (because it's not me who
> controls these routers). So if the problem is with some of these
> routers, I'm afraid we can do nothing about that.

Sure, but that still doesn't explain at all why the expected traffic 
doesn't show up anywhere (ie., the working mail after nmap resolution). 
Such a router cannot prevent us tcpdumping both ends. My point is that we 
would always see the packet at least in the sending end's tcpdump. And, 
would we have the traffic from the end-point tcpdumps, we could trivially 
figure out what the middlebox did to the traffic. 

> > I don't think it was bad at all... :-) I just meant that there wasn't any 
> > other visible traffic, which is very very strange because nothing port 995 
> > related (or anything else) seems to happen during the nmap... Which 
> > network interfaces the server has? Could things get routed through some 
> > other iface during the time of trouble (and during the nmap solution), 
> > that would explain why it isn't visible in the tcpdump which is for the 
> > specific interface.
> 
> fraga@teleporto ~$ ip route list
> 10.1.0.6 dev tun2  proto kernel  scope link  src 10.1.0.5 
> 10.195.195.1 dev tun1  proto kernel  scope link  src 10.195.195.2 
> 192.168.102.0/24 via 10.1.0.6 dev tun2 
> 200.211.201.0/24 dev eth1  proto kernel  scope link  src
> 200.211.201.248 189.38.0.0/16 dev eth0  proto kernel  scope link  src
> 189.38.18.122 default via 189.38.18.121 dev eth0 
> 
> 	Well, if that's the problem I'll be very ashamed for wasting
> your time. Anyway, eveything should go to eth0 interface, through
> 189.38.18.121 gateway.
>
> 	The eth1 interface (200.211.201.248) is an old interface which
> we do not use anymore. So I'm right now deactivating it (I should do
> that for a long time ago). Let's see if the problem remains or not
> (although I have other servers with multiple interfaces and everything
> is fine, since, as far as I understand, what matters is the default
> gateway -- I think that there's no reason to Linux send something to
> eth1 interface since there's only one default gateway).

Agreed, it shouldn't happen. Do you have a static setup for the IPs or is 
there dhcp component which could in theory cause some routing table 
alterations, again I find that unlikely but in the meantime I start to run 
out of ideas how the client and server can speak with each other without 
leaving any traces about it (I hope you really used exactly the tcpdump 
command you told in the mail linking to those stall logs).

> 	Anyway I'm dropping eth1 interface. I'll wait a few days before
> confirming if that's the problem or not.
> 
> 	Thanks again.

There's some NAT somewhere btw because the client uses 192.168.0.2 as 
source address but I don't think that currently has some relevance (it 
might timeout some connections after an idle period, which is usually
of configurable length).


-- 
 i.
---696208474-1677718646-1219872331=:4759--
