From: Marcus Better <marcus@better.se>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Sun, 09 Jul 2006 09:23:04 +0200
Message-ID: <44B0AED8.3040604@better.se>
References: <e82qhq$4v0$1@sea.gmane.org>	<20060630211604.GA5302@electric-eye.fr.zoreil.com> <44AE8CBB.4070409@better.se> <44AFDA3B.6020904@tungstengraphics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	dri-devel@lists.sourceforge.net,
	Alan Hourihane <alanh@tungstengraphics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxfep02.bredband.com ([195.54.107.73]:55455 "EHLO
	mxfep02.bredband.com") by vger.kernel.org with ESMTP
	id S932375AbWGIHXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 03:23:17 -0400
To: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
In-Reply-To: <44AFDA3B.6020904@tungstengraphics.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Hellstr=F6m wrote:
> I guess you got the wrong commit, and the correct one should be the o=
ne
> where Dave adds vblank interrupts. It should be close to the one you
> listed.

I thought I double-checked that it was the right commit, but will check
again.

> If the network sits on the same IRQ line, it will be disabled as well=
=2E

It appears to be on a different IRQ:
~$ cat /proc/interrupts
           CPU0
  0:     202574          XT-PIC  timer
  1:       2649          XT-PIC  i8042
  2:          0          XT-PIC  cascade
  8:          0          XT-PIC  rtc
  9:          0          XT-PIC  acpi
 10:       1059          XT-PIC  yenta, Intel 82801CA-ICH3 Modem, Intel
82801CA-ICH3
 11:      40776          XT-PIC  uhci_hcd:usb1, uhci_hcd:usb2, eth0
 12:     100433          XT-PIC  i8042
 14:      63563          XT-PIC  ide0
 15:       6773          XT-PIC  ide1
NMI:          0
ERR:          0

(This is without i915 loaded though.)

> If you check your kernel logs, you will probably have
> messages about disabled IRQs.

Correct. Here's an example:

Jul  7 16:43:39 kelev kernel: irq 11: nobody cared (try booting with th=
e
"irqpoll" option)
Jul  7 16:43:39 kelev kernel:  [<c0138b74>] __report_bad_irq+0x24/0x90
Jul  7 16:43:39 kelev kernel:  [<c0138c82>] note_interrupt+0x72/0xc0
Jul  7 16:43:39 kelev kernel:  [<c013862e>] __do_IRQ+0xae/0xc0
Jul  7 16:43:39 kelev kernel:  [<c0104a69>] do_IRQ+0x19/0x30
Jul  7 16:43:39 kelev kernel:  [<c01030c2>] common_interrupt+0x1a/0x20
Jul  7 16:43:39 kelev kernel:  [<c011c4fe>] __do_softirq+0x2e/0xa0
Jul  7 16:43:39 kelev kernel:  [<c011c597>] do_softirq+0x27/0x30
Jul  7 16:43:39 kelev kernel:  [<c0104a6e>] do_IRQ+0x1e/0x30
Jul  7 16:43:39 kelev kernel:  [<c01030c2>] common_interrupt+0x1a/0x20
Jul  7 16:43:39 kelev kernel:  [<c0102ef5>] syscall_call+0x7/0xb
Jul  7 16:43:39 kelev kernel: handlers:
Jul  7 16:43:39 kelev kernel: [<e01270c0>] (usb_hcd_irq+0x0/0x60 [usbco=
re])
Jul  7 16:43:39 kelev kernel: [<e01270c0>] (usb_hcd_irq+0x0/0x60 [usbco=
re])
Jul  7 16:43:39 kelev kernel: [<e0044160>] (rtl8139_interrupt+0x0/0x1d0
[8139too]
)
Jul  7 16:43:39 kelev kernel: Disabling IRQ #11

Jul  7 16:44:03 kelev kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jul  7 16:44:03 kelev kernel: eth0: Transmit timeout, status 0c 0005
c07f media 9
0.
Jul  7 16:44:03 kelev kernel: eth0: Tx queue start entry 48  dirty entr=
y 44.
Jul  7 16:44:03 kelev kernel: eth0:  Tx descriptor 0 is 0008a062. (queu=
e
head)
Jul  7 16:44:03 kelev kernel: eth0:  Tx descriptor 1 is 0008a062.
Jul  7 16:44:03 kelev kernel: eth0:  Tx descriptor 2 is 0008a062.
Jul  7 16:44:03 kelev kernel: eth0:  Tx descriptor 3 is 0008a062.
Jul  7 16:44:03 kelev kernel: eth0: link up, 100Mbps, full-duplex, lpa
0x45E1


