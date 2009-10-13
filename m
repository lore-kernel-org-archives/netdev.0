From: jamal <hadi@cyberus.ca>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet
	packets in ifb?!
Date: Tue, 13 Oct 2009 08:21:17 -0400
Message-ID: <1255436477.6305.2.camel@dogo.mojatatu.com>
References: <200910121143.39924.denys@visp.net.lb>
	 <200910130054.23237.denys@visp.net.lb>
	 <1255385250.5406.43.camel@dogo.mojatatu.com>
	 <200910130144.04910.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f186.google.com ([209.85.221.186]:36879 "EHLO
	mail-qy0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759616AbZJMMYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 08:24:55 -0400
Received: by qyk16 with SMTP id 16so3104528qyk.15
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 05:24:18 -0700 (PDT)
In-Reply-To: <200910130144.04910.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-10-13 at 01:44 +0300, Denys Fedoryschenko wrote:

> It kills me :-) Each new version it doesn't work and i notice, i'm almost one  
> who use it :-) Probably i should wait till netfilter API and iptables 
> conversion will stabilize somehow.
> 

I am a little frustrated - but yeah, waiting may help. I tend to do a
lot of private support to fix integration with iptables problems, so you
are not the only user ;->. I wish one distro gets it right.
The most hopeful seems to be debian.

> Plus skbedit in some cases will be faster, if i eliminate iptables, unloading 
> modules even, basic filtering can be done by iproute2 too, i won't have 
> netfilter locks that make things slow on SMP (at least what i heard here and 
> what oprofile shows, that MARK was small CPU hog to compare with skbedit).
> 

Makes sense.

> I am happily running 2k pppoe users on Quad Core CPU/on supercheap r8169
> (better nic not available here) with skbedit and flow classifier. It can do 
> more even, i think.

I bet pppd in user space is probably your biggest problem in terms of
performance.

> After switching to skbedit things improve a lot (before 1k users was near max)
> 

Not using netfilter will improve your numbers. So can skbedit do fwmark
as well?

> I can test even, even if he won't.
> As i understand, for pppoe case, he can just skip offset for ethernet and 
> pppoe header, and he can filter by ip, or not?
> Current way is maybe better, cause someone who want to count everything with 
> ethernet and pppoe headers - can, and who want without - also can (by setting 
> offset , just a bit more difficult.
> 
> Like 
> /sbin/tc filter add dev eth1 protocol 0x8864  parent 2:0 prio 1 u32 \
> match u32 0x$IPREMOTE_HEX 0xffffffff at 24 flowid 2:$ID
> (found in LARTC)

yes, something like that. 
It may be easier to tcpdump -x on both pppoe and ifb and see how the
packets look like at what offset. If that doesnt work well, I will work
on a patch...

cheers,
jamal

