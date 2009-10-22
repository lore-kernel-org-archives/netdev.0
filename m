From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: Re: [PATCH  kernel 2.6.32-rc5] pcnet_cs: add cis of PreMax PE-200
 ethernet pcmcia card
Date: Thu, 22 Oct 2009 20:10:06 +0900
Message-ID: <20091022201006.1fdfb5cc.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091018103920.ca9217ee.ken_kawasaki@spring.nifty.jp>
	<1256152686.8469.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg501.nifty.com ([202.248.238.81]:29523 "EHLO
	userg501.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754961AbZJVLLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 07:11:08 -0400
In-Reply-To: <1256152686.8469.34.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

>Dan Williams <dcbw@redhat.com> wrote:

> > add cis of PreMax ethernet pcmcia card,
> > and some Sierra Wireless serial card(AC555, AC7xx, AC8xx).
 
> Random question: are CIS files copyrightable?  

The CIS contains the IRQ, ioport-range, voltage information etc
like the PCI config space.
So I think it is not copyrightable.
but Sierra Wireless provided this CIS by GPL.

> What exactly do they
> contain, just updates to the the CIS data on the card itself that the
> manufacturer forgot to burn before shipping the card?

The reason for the CIS update is original CIS does not conform to the pcmcia spec,
not forget to burn the CIS.  
 
> Also, I've got a Sierra AC860 here that reports as "prod_id(2):
> "AC860"", and has the same manf_id (0x0192) and card_id (0x710) as the
> AC850.

Actually, not all Sierra Wireless card need the CIS update.

Could you remove the PCMCIA_DEVICE_CIS_PROD_ID12 and PCMCIA_DEVICE_CIS_MANF_CARD
definition of the Sierra Wireless card,
and check the AC860 works or not?


Here is the output of dumpcis for SW_8xx_SER.cis.

Socket 0
offset 0x02, tuple 0x01, link 0x01
  ff 
dev_info
  no_info

offset 0x05, tuple 0x17, link 0x03
  41 00 ff 
attr_dev_info
  EEPROM 250ns, 512b

offset 0x0a, tuple 0x20, link 0x04
  92 01 10 07 
manfid 0x0192, 0x0710

offset 0x10, tuple 0x21, link 0x02
  02 00 
funcid serial_port

offset 0x14, tuple 0x15, link 0x2f
  07 00 53 69 65 72 72 61 20 57 69 72 65 6c 65 73 
  73 00 41 43 38 35 30 00 33 47 20 4e 65 74 77 6f 
  72 6b 20 41 64 61 70 74 65 72 00 52 31 00 ff 
vers_1 7.0, "Sierra Wireless", "AC850", "3G Network Adapter", "R1"

offset 0x45, tuple 0x1a, link 0x05
  01 03 00 07 73 
config base 0x0700 mask 0x0073 last_index 0x03

offset 0x4c, tuple 0x1b, link 0x10
  e0 01 19 78 4d 55 5d 25 a3 60 f8 48 07 30 bc 86 
cftable_entry 0x20 [default]
  Vcc Istatic 45mA Iavg 50mA Ipeak 55mA Idown 20mA
  io 0x48f8-0x48ff [lines=3] [8bit] [range]
  irq mask 0x86bc [level]

offset 0x5e, tuple 0x1b, link 0x08
  a1 01 08 a3 60 f8 47 07 
cftable_entry 0x21
  io 0x47f8-0x47ff [lines=3] [8bit] [range]

offset 0x68, tuple 0x1b, link 0x08
  a2 01 08 a3 60 e8 48 07 
cftable_entry 0x22
  io 0x48e8-0x48ef [lines=3] [8bit] [range]

offset 0x72, tuple 0x1b, link 0x08
  a3 01 08 a3 60 e8 47 07 
cftable_entry 0x23
  io 0x47e8-0x47ef [lines=3] [8bit] [range]

offset 0x7c, tuple 0x1b, link 0x04
  a4 01 08 23 
cftable_entry 0x24
  io 0x0000-0x0007 [lines=3] [8bit]

offset 0x82, tuple 0x14, link 0x00
no_long_link


Best Regards
Ken.
