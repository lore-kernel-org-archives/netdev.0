From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] (5/6) ibmtr -- probe2
Date: Fri, 17 Oct 2003 10:37:41 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF5D2BA91F.A6EBFE7D-ON84256DC2.004A9DE9-84256DC2.004ADCCD@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


In ibmtr_cs.c:

>+static int ibmtr_init(struct net_device *dev)
>+{
>+    extern int ibmtr_probe1(struct net_device *, int);
>+
>+    return ibmtr_probe1(dev, dev->base_addr);
>+}
>+
> /*======================================================================

>     ibmtr_attach() creates an "instance" of the driver, allocating
>@@ -194,7 +200,8 @@

>     link->irq.Instance = info->dev = dev;
>
>-    dev->init = &ibmtr_probe;
>+    dev->init = ibmtr_init;
>+

This changes dev->init from calling ibmtr_probe to ibmtr_probe1. The probe
routines are specifically split into two because of ibmtr_cs. It doesn't
need to do second probe routing because all the memory spaces get allocated
by the pcmcia driver. Trying to allocate the same IO mem area will fail
because its already been allocated by ibmtr_cs.

Mike
