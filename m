From: Nix <nix@esperi.org.uk>
Subject: Re: [net-next 5/9] e1000e: Disable ASPM L1 on 82574
Date: Thu, 03 May 2012 21:17:04 +0100
Message-ID: <87sjfhaukf.fsf@spindle.srvr.nix>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1336038992-3144-6-git-send-email-jeffrey.t.kirsher@intel.com>
	<87d36ld1as.fsf@spindle.srvr.nix>
	<9BBC4E0CF881AA4299206E2E1412B6261882C3A9@FMSMSX151.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	Chris Boot <bootc@bootc.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo\@redhat.com" <gospo@redhat.com>,
	"sassmann\@redhat.com" <sassmann@redhat.com>
To: "Wyborny\, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:60980 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752792Ab2ECURQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 16:17:16 -0400
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B6261882C3A9@FMSMSX151.amr.corp.intel.com>
	(Carolyn Wyborny's message of "Thu, 3 May 2012 20:12:47 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 May 2012, Carolyn Wyborny told this:

> It would be good to know why/how your system is re-enabling the
> setting. The problem is not solvable in firmware unfortunately and is
> somewhat platform dependent. MMIO-tracer might be used to try and see

I entirely forgot about that tool! *Definitely* worth trying.

I'll give it a try this weekend.

> when the re-enabling config space is written, but it might be too
> heavyweight for a live production system.

Given that the re-enabling happens at around the same time as the boot
scripts finish running (it's done by the time I can log in), that's not
going to be a problem. Hence my speculation that it's being re-enabled
when the interface stabilizes (which is, of course, asynchronous) or
something like that.

> I am also working on a patch to the driver to detect the condition and
> then do a slot reset to avoid a whole system reboot. Would you be
> willing to test it in your problem system?

Yes, definitely. The whole-system reboot is irritating because the
system is headless, and with its NICs dead that means a big red switch
to reboot when this problem strikes, which gives me the heebie-jeebies
:)

(Turning off ASPM definitely completely fixes it, so it *is* this bug.
It's just getting the disabling to stick that's proving tricky.)

-- 
NULL && (void)
