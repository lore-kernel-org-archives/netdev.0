From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [net-next 5/9] e1000e: Disable ASPM L1 on 82574
Date: Thu, 3 May 2012 20:12:47 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B6261882C3A9@FMSMSX151.amr.corp.intel.com>
References: <1336038992-3144-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1336038992-3144-6-git-send-email-jeffrey.t.kirsher@intel.com>
 <87d36ld1as.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Chris Boot <bootc@bootc.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Nix <nix@esperi.org.uk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64938 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876Ab2ECUMt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 16:12:49 -0400
In-Reply-To: <87d36ld1as.fsf@spindle.srvr.nix>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Nix [mailto:nix@esperi.org.uk]
>Sent: Thursday, May 03, 2012 3:09 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Chris Boot; netdev@vger.kernel.org;
>gospo@redhat.com; sassmann@redhat.com; Wyborny, Carolyn
>Subject: Re: [net-next 5/9] e1000e: Disable ASPM L1 on 82574
>
 [..]
>(reminder: this is known not to fix the instance of this problem I am
>experiencing, where ASPM is being re-enabled by something even if turned
>off via setpci during boot, though it does fix those instances seen by
>others where that doesn't happen. I'd have done more printf()-scattering
>debugging to see where it's turned back on if it wasn't that this is
>happening on an always-on server for which rebooting outside the dead of
>night is a long-winded chore...)
>
>FWIW I have also seen -- very rare -- lockups of the same nature on
>82574L links in 100MbE mode using non-jumbo frames. However they are far
>more common on GbE jumbo-framed links, normally taking less than an hour
>to take the link down with a wildly corrupted register set (as shown by
>ethtool).
>
>(It's annoying this firmware isn't flashable so we could just *fix* this
>bug rather than working around it. :( )
>
>
>I think I might cheat a bit next and printk_once() the state of ASPM L1
>on the errant PCI device from inside the scheduler when it flips from L1
>off to L1 on again. At 100 tests per second that should indicate at what
>time the thing is turned back on fairly tightly: even if not providing a
>direct clue as to which bit of the kernel is doing it, if I combine it
>with a set -x in userspace it should at least indicate what bit of the
>boot process is happening at the same time. It'll be the weekend before
>I can try that though.
>
>--
>NULL && (void)

Hello,

It would be good to know why/how your system is re-enabling the setting.  The problem is not solvable in firmware unfortunately and is somewhat platform dependent. MMIO-tracer might be used to try and see when the re-enabling config space is written, but it might be too heavyweight for a live production system.

I am also working on a patch to the driver to detect the condition and then do a slot reset to avoid a whole system reboot.  Would you be willing to test it in your problem system?

Thanks,

Carolyn
