From: Vadim Dyadkin <dyadkin@lns.pnpi.spb.ru>
Subject: Re: troubles with r8169
Date: Mon, 13 Aug 2007 00:58:51 +0400
Message-ID: <46BF748B.9090504@lns.pnpi.spb.ru>
References: <fa.BZqd/vLw75Xm+ORj+HLjUzU1hSw@ifi.uio.no> <46BF61AB.5060400@shaw.ca> <46BF6853.4020800@lns.pnpi.spb.ru> <200708122138.58405.alistair@devzero.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Hancock <hancockr@shaw.ca>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alistair John Strachan <alistair@devzero.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dimail1.hmi.de ([134.30.95.50]:40004 "EHLO dimail1.hmi.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758887AbXHLU7i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2007 16:59:38 -0400
In-Reply-To: <200708122138.58405.alistair@devzero.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alistair John Strachan =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Thank for your answer. This problem never shows up if I use only nvi=
dia
>> driver (the work without network), or if I use only r8169 (without
>> x.org). If I use both of them I have the hang. Usually the hang appe=
ars
>> if OpenGL is used or network rate is maximal. I tested this regimes =
many
>> times before.
>
> If you haven't already, I'd drop linux-bugs@nvidia.com an email to se=
e if they=20
> have any insight.=20

I haven't done it yet. I'm going to do it.

> Not that this can't be a kernel bug, just that it's a bit=20
> difficult for kernel developers to debug when you're using a driver f=
or which=20
> we don't have the sources.
>
> As for changing the IRQ assignments, I don't have any immediate sugge=
stions. I=20
> notice that this laptop has a dual core processor, so I'm guessing di=
sabling=20
> APIC isn't an option. Have you tried that anyway, just to see if the =
IRQ=20
> assignment differs?

If I've correctly understood your suggestion I should load kernel with
'noapic' option. In that case the situation even worse:
******************************
           CPU0       CPU1
  0:     106543      11922    XT-PIC-XT        timer
  1:         53          8    XT-PIC-XT        i8042
  2:          0          0    XT-PIC-XT        cascade
  5:          0          0    XT-PIC-XT        sdhci:slot0
  7:      14250     126092    XT-PIC-XT        ehci_hcd:usb2
  8:          2          0    XT-PIC-XT        rtc
  9:       1168        190    XT-PIC-XT        acpi
 10:        338        181    XT-PIC-XT        HDA Intel
 11:       7167       1052    XT-PIC-XT        ohci_hcd:usb1, yenta,
eth0, nvidia
 12:        123          9    XT-PIC-XT        i8042
 14:         19         32    XT-PIC-XT        ide0
 15:      10936       1112    XT-PIC-XT        ide1
NMI:          0          0
LOC:      11921     106401
ERR:      41370
MIS:          0
*******************************
Now, pcmcia and usb 1.1 share the same IRQ.

Plus, dmesg says:
*********************************
irq 7: nobody cared (try booting with the "irqpoll" option)
 [<c013f9c4>] __report_bad_irq+0x24/0x80
 [<c013fc46>] note_interrupt+0x226/0x260
 [<f885d0bb>] usb_hcd_irq+0x2b/0x60 [usbcore]
 [<c013eed5>] handle_IRQ_event+0x25/0x50
 [<c01407f3>] handle_level_irq+0x93/0x100
 [<c010529b>] do_IRQ+0x3b/0x70
 [<c010293e>] sys_sigreturn+0xce/0xe0
 [<c010341b>] common_interrupt+0x23/0x28
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
handlers:
[<f885d090>] (usb_hcd_irq+0x0/0x60 [usbcore])
Disabling IRQ #7
******************************

Vadim

