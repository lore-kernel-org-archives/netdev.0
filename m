From: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 28 Jul 2009 09:21:27 +0200
Message-ID: <4A6EA6F7.1020203@gibraltar.at>
References: <4A65EC3F.4050400@gibraltar.at>	<20090723102848.00a56ad1@nehalam>	<4A6D8975.4050000@gibraltar.at> <20090727093018.4a830259@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jupiter1.gibraltar.at ([80.120.3.98]:39966 "EHLO
	mail1.gibraltar.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753485AbZG1HVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 03:21:35 -0400
In-Reply-To: <20090727093018.4a830259@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Stephen Hemminger wrote:
> On Mon, 27 Jul 2009 13:03:17 +0200
> Rene Mayrhofer <rene.mayrhofer@gibraltar.at> wrote:
> 
>> Stephen Hemminger schrieb:
>>> You could try commenting out sky2_shutdown which does the Wol
>>> power down stuff. Maybe changing setting of Wake On Lan would
>>> help as well.
>>>
>>> What happens if you take interface down 'ip link set eth0 down' (or ifconfig)?
>>>
>>> There are several different register writes in the shutdown path.
>>> You could add code to check if a particular access is disabling
>>> the PCI buss with:
>>>
>>>     sky2_write(... som register...)
>>>     BUG_ON(sky2_read16(sky2->hw, B0_CTST) == 0xffff);
>> I tried adding that wherever it seemed to make sense, resulting in
> 
> Does the platform use MSI? Perhaps it generates a bogus interrupt when
> powered off.

Potentially:

[root@gibraltar3-esys-master ~]# cat /proc/interrupts
           CPU0
  0:        311   IO-APIC-edge      timer
  1:          2   IO-APIC-edge      i8042
  2:          0    XT-PIC-XT        cascade
  4:        440   IO-APIC-edge      serial
  7:          0   IO-APIC-edge      parport0
  8:         87   IO-APIC-edge      rtc0
 14:     124214   IO-APIC-edge      ide0
 15:          0   IO-APIC-edge      ide1
 19:         95   IO-APIC-fasteoi   ata_piix
 20:        962   IO-APIC-fasteoi   asak
 21:       3644   IO-APIC-fasteoi   testnet
 22:     108021   IO-APIC-fasteoi   hb
 23:          0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb2, voip
504:     188598   PCI-MSI-edge      lan
505:       7989   PCI-MSI-edge      dmz
506:     317686   PCI-MSI-edge      gibsrv
507:      84129   PCI-MSI-edge      wan
NMI:          0   Non-maskable interrupts
LOC:   11928173   Local timer interrupts
RES:          0   Rescheduling interrupts
CAL:          0   Function call interrupts
TLB:          0   TLB shootdowns
TRM:          0   Thermal event interrupts
SPU:          0   Spurious interrupts
ERR:          0
MIS:          0

Do I interpret this correctly that MSI is used by sky2 (those above are
the network interface names)? Sorry for my ignorance in this regard, but
I haven't consciously used or debugged MSI so far.

best regards,
Rene
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkpupvcACgkQq7SPDcPCS94ULQCgkcTQe5/HepuXuncx4grujtrv
adwAoOIERCJIVph/uwPTjVAwDQj7vnBC
=4/Xu
-----END PGP SIGNATURE-----
