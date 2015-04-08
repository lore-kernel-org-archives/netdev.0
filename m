From: Nix <nix@esperi.org.uk>
Subject: Re: [PATCH RFT net-next #2 0/6] via-rhine receive buffers rework
Date: Wed, 08 Apr 2015 23:43:55 +0100
Message-ID: <87mw2iw89g.fsf@spindle.srvr.nix>
References: <cover.1428445141.git.romieu@fr.zoreil.com>
	<87vbh6364u.fsf@spindle.srvr.nix>
	<20150408215051.GA25326@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:41952 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbbDHWoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 18:44:03 -0400
In-Reply-To: <20150408215051.GA25326@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Wed, 8 Apr 2015 23:50:51 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 Apr 2015, Francois Romieu stated:

> Nix <nix@esperi.org.uk> :
> [...]
>> I am sorry to report that I just had a watchdog-triggered autoreboot
>> during testing of this patch series :( with no log messages of any kind.
>> looks like the underlying bug is still there, or another bug with the
>> same symptoms (i.e. some way to crash inside the rx handler). I qwish I
>> could get some debugging output when this happens!
>
> You may add the patch below on top of the current stack. I don't expect
> much difference. Increasing RX_RING_SIZE could be a different story.

Will try it tomorrow.

> Did you keep netconsole disabled and did you increse via-rhine verbosity
> level ?

netconsole is active. The verbosity level is default because I didn't
notice the driver had one to set! I'll push it up and see what happens.
I don't expect too much: this is, after all, a uniprocessor, and if
you're stuck in an interrupt handler there's not much it can do...

> No shared IRQ ?

None relevant that I can see:

           CPU0
  0:     692019    XT-PIC  timer
  2:          0    XT-PIC  cascade
  4:        314    XT-PIC  serial
  5:     114062    XT-PIC  adsl
  7:     329914    XT-PIC  cs5535-clockevt
  9:     137080    XT-PIC  bdsl
 10:       2006    XT-PIC  voip
 11:    1546540    XT-PIC  gordianet
 12:     724187    XT-PIC  wireless
 14:      12313    XT-PIC  pata_cs5536
 15:     219702    XT-PIC  ehci_hcd:usb1, ohci_hcd:usb2

The only shared interrupt is usb2, and since that's an
internal-to-the-case thing that's not plugged in to anything, in effect
there are none shared at all. (The unplugged interfaces *are* shared --
the last four of the eight interfaces on the box run 10, 7, 10, 7 -- but
since only one of those has anything plugged into it, the net effect is
no sharing.)

My load tests are being performed between the gordianet and wireless
interfaces, IRQs 11 and 12, which are entirely unshared.

>> However, to give some good news, CPU usage is much lower than before the
>> patch: si ~10%, rather than ~80% with spikes of full CPU usage:
>> ksoftirqd's CPU usage is steady at about 3% rather than 40--60% with
>> spikes to 100%, and some of that will be USB interrupts from the
>> continuous USB traffic from my entropy key.
>
> Huuuuh ? Which entropy key ?

It's a USB device that gives you about 4KiB/s over USB:
<http://www.entropykey.co.uk/>. No longer manufactured, alas :(
but as it provides entropy continuously it is a continuous source of
interrupts. (But from the USB port, obviously.)

-- 
NULL && (void)
