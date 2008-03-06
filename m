From: jamal <hadi@cyberus.ca>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Thu, 06 Mar 2008 09:27:14 -0500
Message-ID: <1204813634.4440.59.camel@localhost>
References: <20080224222035.M62480@visp.net.lb>
	 <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb>
	 <20080225113930.GA4733@ff.dom.local> <20080305103935.M76165@visp.net.lb>
	 <20080306134015.GA4571@ff.dom.local>  <20080306135625.M25627@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:2157 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971AbYCFO1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 09:27:18 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1262833rvb.1
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2008 06:27:17 -0800 (PST)
In-Reply-To: <20080306135625.M25627@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-06-03 at 15:57 +0200, Denys Fedoryshchenko wrote:
> I am able to reproduce this warning over this relatively simple shell script
> on my Gentoo PC (2.6.25-rc3).
> http://www.nuclearcat.com/files/bug_feb.txt
> 

That script looks pretty sane to me - nothing super-exciting. I suspect
you eventually want them all to look like ifb1 on the egress.
Do you see the same issue without the ifb1 speacial case?

> Probably it will help to debug issue for more experienced developers. Note:
> it appears not immediately, second time i tested, it's appeared after while,
> but in matter of seconds.

I wonder is there some latency from the moment you insmod ifb to the
moment the tc rules take effect? Will it still happen if you dont have
modules?
Also note, that lock dependency is a bit strange, Jarek correct me if i
am wrong; it seems to say:
a packet received on ingress of some e1000 (ethx) gets acted on by
mirred which ends grabbing lock of an ifb device - this part should be
fine and no need for the alarm. The alarm seems to be a result of a
loopback device that is being registered in between the two activities.
i.e there are three devices affected with entirely different locks(ethx,
ifbx, and loopback). Smells like lockdep is getting it wrong?

> Note - it can stop traffic on PC completely. It is also seems crashed my 
> desktop PC, i am not able to execute "tc qdisc del dev eth0 root".
> The system hang completely. I had few similar issues on my PPPoE servers 
> (with different scripts for shapers), that system hang, and even "reboot -f" 
> doesn't work sometimes.

This sounds like a different issue from above - when did this start to
happen? Is it at the same time as above warnings showing up?

cheers,
jamal



