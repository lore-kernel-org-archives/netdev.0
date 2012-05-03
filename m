From: Nix <nix@esperi.org.uk>
Subject: Re: [net-next 5/9] e1000e: Disable ASPM L1 on 82574
Date: Thu, 03 May 2012 11:08:43 +0100
Message-ID: <87d36ld1as.fsf@spindle.srvr.nix>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1336038992-3144-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, Chris Boot <bootc@bootc.net>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	"Wyborny\, Carolyn" <carolyn.wyborny@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:59223 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756687Ab2ECKI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 06:08:56 -0400
In-Reply-To: <1336038992-3144-6-git-send-email-jeffrey.t.kirsher@intel.com>
	(Jeff Kirsher's message of "Thu, 3 May 2012 02:56:28 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 May 2012, Jeff Kirsher spake thusly:

> From: Chris Boot <bootc@bootc.net>
>
> ASPM on the 82574 causes trouble. Currently the driver disables L0s for
> this NIC but only disables L1 if the MTU is >1500. This patch simply
> causes L1 to be disabled regardless of the MTU setting.
>
> Signed-off-by: Chris Boot <bootc@bootc.net>
> Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
> Cc: Nix <nix@esperi.org.uk>
> Link: https://lkml.org/lkml/2012/3/19/362
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

(reminder: this is known not to fix the instance of this problem I am
experiencing, where ASPM is being re-enabled by something even if turned
off via setpci during boot, though it does fix those instances seen by
others where that doesn't happen. I'd have done more printf()-scattering
debugging to see where it's turned back on if it wasn't that this is
happening on an always-on server for which rebooting outside the dead of
night is a long-winded chore...)

FWIW I have also seen -- very rare -- lockups of the same nature on
82574L links in 100MbE mode using non-jumbo frames. However they are far
more common on GbE jumbo-framed links, normally taking less than an hour
to take the link down with a wildly corrupted register set (as shown by
ethtool).

(It's annoying this firmware isn't flashable so we could just *fix* this
bug rather than working around it. :( )


I think I might cheat a bit next and printk_once() the state of ASPM L1
on the errant PCI device from inside the scheduler when it flips from L1
off to L1 on again. At 100 tests per second that should indicate at what
time the thing is turned back on fairly tightly: even if not providing a
direct clue as to which bit of the kernel is doing it, if I combine it
with a set -x in userspace it should at least indicate what bit of the
boot process is happening at the same time. It'll be the weekend before
I can try that though.

-- 
NULL && (void)
