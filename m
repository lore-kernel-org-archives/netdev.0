From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: [PATCH] Silence cs89x0
Date: Sun, 28 Mar 2004 00:50:30 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403280050.31010.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403262202.56861.vda@port.imtp.ilyichevsk.odessa.ua> <4064922D.1030306@pobox.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_2UgZAhGI7ZOmqEJ"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4064922D.1030306@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_2UgZAhGI7ZOmqEJ
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 26 March 2004 22:27, Jeff Garzik wrote:
> Denis Vlasenko wrote:
> > This is the most talkative NIC driver in my .config:
> >
> > cs89x0:cs89x0_probe(0x0)
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > PP_addr=0xffff
> > eth0: incorrect signature 0xffff
> > cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP
>
> Not bad, but what about a patch that notices the 0xffff address, and
> assumes it won't find anything?

It does not access port 0xffff. It tries to say that it probed for hardware
and:
PP_addr=0xffff - inw(ioaddr + ADD_PORT) returned all foxes
eth0: incorrect signature 0xffff - inw(ioaddr + DATA_PORT) returned all foxes,
which is not known EISA id. Pretty cryptic :)

Maybe this patch?
--
vda

--Boundary-00=_2UgZAhGI7ZOmqEJ
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="cs89x0.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="cs89x0.diff"

--- cs89x0.c.orig	Wed Mar 17 22:54:08 2004
+++ cs89x0.c	Sun Mar 28 00:48:19 2004
@@ -455,10 +455,11 @@
 		ioaddr &= ~3;
 		outw(PP_ChipID, ioaddr + ADD_PORT);
 	}
-printk("PP_addr=0x%x\n", inw(ioaddr + ADD_PORT));
+	printk(KERN_DEBUG "%s: ioaddr=0x%04x PP_addr=0x%04x\n", dev->name,
+		ioaddr, inw(ioaddr + ADD_PORT));
 
 	if (inw(ioaddr + DATA_PORT) != CHIP_EISA_ID_SIG) {
-		printk(KERN_ERR "%s: incorrect signature 0x%x\n",
+		printk(KERN_DEBUG "%s: incorrect signature 0x%04x\n",
 			dev->name, inw(ioaddr + DATA_PORT));
   		retval = -ENODEV;
   		goto out2;

--Boundary-00=_2UgZAhGI7ZOmqEJ--
