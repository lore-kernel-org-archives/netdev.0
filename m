From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: [PATCH] Silence cs89x0
Date: Fri, 26 Mar 2004 22:02:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403262202.56861.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_wxIZAvvUC50yjug"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_wxIZAvvUC50yjug
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

I need to use lots of different eth cards at work.
My kernel has lots of eth drivers compiled in.
At boot they try to find supported hardware.

cs89x0 is especially noisy and prints almost
a screenful of debug info. This patch makes those
printks go KERN_DEBUG way.

Run tested on 2.6.5-rc1
--
vda

--Boundary-00=_wxIZAvvUC50yjug
Content-Type: text/x-diff;
  charset="us-ascii";
  name="cs89x0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="cs89x0.patch"

This is the most talkative NIC driver in my .config:

cs89x0:cs89x0_probe(0x0)
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
PP_addr=0xffff
eth0: incorrect signature 0xffff
cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP

This patch makes these printks KERN_DEBUG

--- linux-2.6.5-rc1/drivers/net/cs89x0.c.orig	Wed Mar 17 22:54:08 2004
+++ linux-2.6.5-rc1/drivers/net/cs89x0.c	Fri Mar 26 00:52:30 2004
@@ -455,10 +455,10 @@
 		ioaddr &= ~3;
 		outw(PP_ChipID, ioaddr + ADD_PORT);
 	}
-printk("PP_addr=0x%x\n", inw(ioaddr + ADD_PORT));
+	printk(KERN_DEBUG "PP_addr=0x%x\n", inw(ioaddr + ADD_PORT));
 
 	if (inw(ioaddr + DATA_PORT) != CHIP_EISA_ID_SIG) {
-		printk(KERN_ERR "%s: incorrect signature 0x%x\n",
+		printk(KERN_DEBUG "%s: incorrect signature 0x%x\n",
 			dev->name, inw(ioaddr + DATA_PORT));
   		retval = -ENODEV;
   		goto out2;

--Boundary-00=_wxIZAvvUC50yjug--
