From: Sven Suhl <S.Suhl@assenmacher.net>
Subject: Patch: drivers/net/3c59x.c
Date: Thu, 6 May 2004 14:30:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <A30ABA3AC41ED411B66A00E07D7D5F2F3C7613@inter01.assenmacher.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi anybody,



got some problems with my laptop's ethernet device (it's a medion laptop
based on an ati board, using a 3com etherlink3). It seems that medion is
modyfing some parts of the used hardware. So here is what I got: Under w2k
the eth-dev says it is an '3c902B-WMB-ENM Integrated Fast Ethernet'. To
linux it introduces itself as 10b7:9202. Reading the eeprom out of it says
it is in fact a 9201 chip. So I tried the settings from the 9201. With the
following options in modules.conf (or modprobe.conf) this card will start to
work correctly:

alias eth0 3c59x
options eth0 options=0x206 

I have to force it to use mii and full-duplex - I think this depends on the
used network. Without this option the card (or driver???) will only use
10baseT (as defined in eeprom) and won't detect correct bandwith... Maybe
someone knows how to fix this problem and tells it to me so that I can test
it out.

Btw. Could somebody do me the favour to add the following lines to the
3c59x.c source in the kernel to make this card available to it? Currently
I'm using kernel 2.6.5. Sorry that I do not know how to use patch and those
diff utitilities...:

// added to the end of 'enum vortex_chips'
CH_902B_EMB_WNM, 

// added to the end of 'static struct vortex_chip_info'
{"3c902B-EMB-WNM Integrated Fast Ethernet",
 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|HAS_HWCKSM, 128, },

// added to the end of 'vortex_pci_tbl'
{ 0x10B7, 0x9202, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_902B_EMB_WNM },



Thx and a nice day

Sven Suhl
