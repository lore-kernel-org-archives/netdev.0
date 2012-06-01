From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: IO_PAGE_FAULT & netdev watchdog
Date: Fri, 1 Jun 2012 22:13:57 +0200
Message-ID: <20120601201357.GA22597@electric-eye.fr.zoreil.com>
References: <201205312331.06623.plr.vincent@gmail.com> <20120601125949.GA11973@electric-eye.fr.zoreil.com> <201206012120.43235.plr.vincent@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Vincent Pelletier <plr.vincent@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59620 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759247Ab2FAUW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 16:22:27 -0400
Content-Disposition: inline
In-Reply-To: <201206012120.43235.plr.vincent@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vincent Pelletier <plr.vincent@gmail.com> :
[...]
> If it's bogus, could it be a mis-interpretation of its state when the error 
> occurs (I don't know how CPU knows a fault happened, I guess some IRQ + some 
> register contain error status, address of error, some process/context 
> identifier) ?

See "AMD I/O Virtualization Technology (IOMMU) Specification".

> Or hardware bug ? Or MMU misconfiguration for some reason ?

I don't have time to poke deeply enough into the iommu code.

[...]
> If it's not bogus, would it be the sign of firmware bug (accessing some 
> unpredictable memory upon certain conditions) ?

That's what I thought first. Or I should have added something to the r8169
driver. However it's quite reproducible, the failing address is one of the
mapped Rx or Tx descriptor ring address - don't remember which one, see
the PR at korg - and it does not fit the timing pattern.

[...]
> I'll try either and both. Given the poor result I got from 
> reset/remove/rescan, I guess I should reboot between attempts, right ?

Yes. The inlined patch could help avoiding the problem but it is not
supposed to help a failed network adapter recovering.

> Should I prevent original module auto-loading at boot ? Maybe more than just 
> r8169 ?

It should not be required. YMMV.

-- 
Ueimor
