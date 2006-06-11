From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Sun, 11 Jun 2006 18:40:54 -0400
Message-ID: <20060611224054.GB13139@redhat.com>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:64940 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751098AbWFKWk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2006 18:40:56 -0400
To: Faidon Liambotis <faidon@cube.gr>
Content-Disposition: inline
In-Reply-To: <20060611222719.GA13139@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 11, 2006 at 06:27:19PM -0400, Dave Jones wrote:
 > On Sat, Jun 10, 2006 at 02:08:50PM -0400, Dave Jones wrote:
 >  > On Sat, Jun 10, 2006 at 08:50:10PM +0300, Faidon Liambotis wrote:
 >  >  > Remove Prism II IDs from the orinoco driver since now we have a separate
 >  >  > driver for them (HostAP). Additionally, kill orinoco_{pci,plx,nortel}
 >  >  > completely, since they only exist to support Prism cards.
 >  >  > No attempt was made to clean up the rest of the driver of the actual
 >  >  > Prism II code, only the PCI IDs were removed.
 >  > 
 >  > I'm fairly certain I have a buffalo card that doesn't work with hostap
 >  > that works just fine with orinoco.  I'll dig it out and see if that
 >  > has been improved.
 > 
 > Objection rescinded, I have a WLI-PCM-L11G, which this patch doesn't affect.

Ah-ha, I had tested the wrong card.
I also have a Sitecom card, which matches this ident you remove in your patch..

PCMCIA_DEVICE_MANF_CARD(0xd601, 0x0002), /* Safeway 802.11b, ZCOMAX AirRunner/XI-300 */


pccardctl ident shows it as:

Socket 0:
  product info: " ", "IEEE 802.11 Wireless LAN/PC Card", "", ""
  manfid: 0xd601, 0x0002
  function: 6 (network)



Under hostap, it's a brick, it won't even report any scanning results.

pccard: PCMCIA card inserted into slot 0
pcmcia: registering new device pcmcia0.0
ieee80211_crypt: registered algorithm 'NULL'
hostap_cs: 0.4.4-kernel (Jouni Malinen <jkmaline@cc.hut.fi>)
hostap_cs: setting Vcc=33 (constant)
Checking CFTABLE_ENTRY 0x01 (default 0x01)
IO window settings: cfg->io.nwin=1 dflt.io.nwin=1
io->flags = 0x0046, io.base=0x0000, len=64
hostap_cs: Registered netdevice wifi0
hostap_cs: index 0x01: , irq 4, io 0x0100-0x013f
prism2_hw_init: initialized in 108 ms
wifi0: NIC: id=0x8002 v1.0.0
wifi0: PRI: id=0x15 v0.3.0
wifi0: STA: id=0x1f v1.3.4
wifi0: defaulting to host-based encryption as a workaround for firmware bug in Host AP mode WEP
wifi0: defaulting to bogus WDS frame as a workaround for firmware bug in Host AP mode WDS
wifi0: registered netdevice wlan0
Scan result translation succeeded (length=0)


With orinoco however, it works just fine..
(Asides from the irritating feature of orinoco that the interface has to be 'up'
 before an iwlist scanning works)


pccard: PCMCIA card inserted into slot 0
pcmcia: registering new device pcmcia0.0
eth1: Hardware identity 8002:0000:0001:0000
eth1: Station identity  001f:0004:0001:0003
eth1: Firmware determined as Intersil 1.3.4
eth1: Ad-hoc demo mode supported
eth1: IEEE standard IBSS ad-hoc mode supported
eth1: WEP supported, 104-bit key
eth1: MAC address 00:60:B3:68:AE:9B
eth1: Station name "Prism  I"
eth1: ready
eth1: index 0x01: , irq 4, io 0x0100-0x013f
ADDRCONF(NETDEV_UP): eth1: link is not ready
eth1: New link status: Connected (0001)
ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready


So with your patch, this card will become totally useless to me.

		Dave

-- 
http://www.codemonkey.org.uk
