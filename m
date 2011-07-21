From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: NIC driver r8168 with r8169 for RTL8111/8168B and DGE-528T together
Date: Thu, 21 Jul 2011 12:22:59 +0200
Message-ID: <20110721102259.GA10481@electric-eye.fr.zoreil.com>
References: <4E26B198.4020606@telkomsa.net> <20110720122206.73898673@nehalam.ftrdhcpuser.net> <4E2752A2.3030208@telkomsa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Danie Wessels <dawessels@telkomsa.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40292 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab1GUKiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 06:38:15 -0400
Content-Disposition: inline
In-Reply-To: <4E2752A2.3030208@telkomsa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Danie Wessels <dawessels@telkomsa.net> :
[...]
> .> Remove the 8168 PCI IDs from the r8169 driver and you should be set.
> gr8. I can give that a try...8^0  (some more hints....?)

Search for rtl8169_pci_tbl and remove the 0x8168 line : the kernel r8169
driver will stop being used on the 8168s.

> 
> .>It ought to be supported by the kernel r8169 driver.
> 
> See bugs listed on Ubuntu:
> https://bugs.launchpad.net/ubuntu/+source/linux-source-2.6.22/+bug/141343

Executive summary :
a. started in 2007
b. includes "kernel r8169 driver does not work, tried Realtek's r8168,
   happy now"
c. includes b. +  "...wait a few days, Oops"
d. covers different devices (8168b, 8168c, plain 8169).
e. people still using old kernel (see post 2.6.26
   77332894c21165404496c56763d7df6c15c4bb09 in #38 then mention of 2.6.22,
   2.6.24)
f. usual "this is the same bug" (#141343 is the same bug as #141343
e. one (1) dmesg attached to the whole thread (74 messages). Tons of lspci,
   not a single XID. 

> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/221499

Trend (?) : recent kernels help. XID and up-to-date reports would be
welcome if they can be streamlined to a standard (for me :o) ) kernel.
See below.

> https://bugs.launchpad.net/linux/+bug/347711

I wish I could filter out comments by author. Flat PR get really, really
messy with time.

> And 0n Bug #347711
> linux-kernel-bugs #12411
> Duplicates of this bug
> Bug #76489
> Bug #347670

Parts of reports look the same but it is more a bag of mixed bugs than
a duplicated one. On the bright side I only have to pick one to fix
something. :o/

> .> Which problem(s) do you have with it ?
> No communication to outside devices. I can not ping my router
> through it but can ping its IP.

So it is receiving packets either in promiscuous mode or (and)
as long as its peer knows its MAC address ?

No Tx at all (it may help if you can capture traffic on the remote
end) or just a few packets before it stops (and spits a NETDEV
WATCHDOG message) ?

> What can I do now or where should I report it or how can I help?
> RTFM 4 rules.d = where?

- Where (general)
  Here and/or kernel.org bugzilla. Cc: good. Private email: bad. You may
  Cc: Hayes as well.
  If you go for bugzilla, fill Product/Component as "Drivers/Network"

- What (general)
  If it is not a regression - i.e. it does not fall in the "stopped
  working" bucket - always try last Linus's -rc or David Miller's "next"
  branch. I may have a bit more pending sauce but the "next" branch usually
  is a good starting point (especially as fixing regressions in it asap is
  a rather high priority task). "next" is waiting for you at :
  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

  Comparing Realtek's driver and kernel r8169 one is welcome. BIOS lan
  options and reboot from a different OS sometimes make a difference (its
  always nice to be sure than the damn thing _can_ work).

  Include:
  - dmesg output (unabbreviated, explicit). The XID line is a mess but it
    allows me to triage the bugs.
  - ethtool -d ethX. Be it a single line or a (nowadays partial) registers
    dump.
  - lspci -v/-tv
  - brand/motherboard identification 

  (wrt your report, I already have most of the needed material)

  Ping me when you want a status update or feel things are sidetracked.

- What (specific)
  One of Ubuntu's report suggests that you are experiencing a regression.
  If so it would be nice to bissect it.

In the short run I can not do more as I must push something out for a mac
address change problem with the 8168evl.

-- 
Ueimor
