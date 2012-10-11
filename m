From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Thu, 11 Oct 2012 14:00:33 +0200
Message-ID: <1349956833.21172.8841.camel@edumazet-glaptop>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <506ED18C.3010009@gmail.com> <20121005140556.GQ4625@n2100.arm.linux.org.uk>
	 <506EEFBB.3060705@gmail.com> <507619FA.6080001@jonmasters.org>
	 <yw1xtxu1pwtv.fsf@unicorn.mansr.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7038@saturn3.aculab.com>
	 <yw1xpq4ppcju.fsf@unicorn.mansr.com>
	 <1349949638.21172.8445.camel@edumazet-glaptop>
	 <1349950926.21172.8521.camel@edumazet-glaptop>
	 <20121011103257.GO4625@n2100.arm.linux.org.uk>
	 <1349952574.21172.8604.camel@edumazet-glaptop>
	 <1349952970.1232.5.camel@sakura.staff.proxad.net>
	 <1349954899.21172.8728.camel@edumazet-glaptop>
	 <1349956055.1232.9.camel@sakura.staff.proxad.net>
	 <1349956456.21172.8820.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, David Laight <David.Laight@ACULAB.COM>,
	Jon Masters <jonathan@jonmasters.org>,
	linux-arm-kernel@lists.infradead.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42916 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385Ab2JKMAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 08:00:38 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so921913bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 05:00:37 -0700 (PDT)
In-Reply-To: <1349956456.21172.8820.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 13:54 +0200, Eric Dumazet wrote:
> On Thu, 2012-10-11 at 13:47 +0200, Maxime Bizon wrote:
> > On Thu, 2012-10-11 at 13:28 +0200, Eric Dumazet wrote:
> > 
> > > You probably are aware that a driver can use : 
> > > 
> > > - a fragment to hold the frame given by the hardware, with whatever
> > > alignment is needed by the hardware.
> > > 
> > > Then allocate an skb with enough room (128 bytes) to pull the headers as
> > > needed later.
> > > 
> > > skb = netdev_alloc_skb_ip_align(dev, 128);
> > 
> > What happen at tx time, supposing that same hardware cannot do SG ?
> > 
> > Aren't we going to memcpy the data into the head ?
> > 
> 
> Of course, if you use a forwarding setup, and the tx driver is not SG
> capable, performance will be bad (You have to copy the data into a
> single skb (linearize the skb)) 

By the way, if said driver also has alignments issues, it will probably
copy the packet given by the stack. (Think you added an IPIP
encapsulation)

It would be better for such driver to still pretend it can do SG,
and it does the copy itself, avoiding the prior copies in core stack.
