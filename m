From: Pavel Roskin <proski@gnu.org>
Subject: Re: [TRIVIAL PATCH] Correctly print MAC address of BMAC
Date: Sat, 20 Mar 2004 14:43:34 -0500 (EST)
Sender: owner-linuxppc-dev@lists.linuxppc.org
Message-ID: <Pine.LNX.4.58.0403201442550.20651@portland.hansa.lan>
References: <Pine.LNX.4.58.0403201433570.20621@portland.hansa.lan>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_Azwbs0bgwDPYonrtkB6GSQ)"
Return-path: <owner-linuxppc-dev@lists.linuxppc.org>
In-reply-to: <Pine.LNX.4.58.0403201433570.20621@portland.hansa.lan>
To: linuxppc-dev@lists.linuxppc.org, netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--Boundary_(ID_Azwbs0bgwDPYonrtkB6GSQ)
Content-type: TEXT/PLAIN; charset=US-ASCII
Content-transfer-encoding: 7BIT

On Sat, 20 Mar 2004, Pavel Roskin wrote:

> Somehow the loop to print the address was moved before the code that
> prints the rest of the line.  The attached patch fixes that.

Sorry, forgot the patch.

--
Regards,
Pavel Roskin

--Boundary_(ID_Azwbs0bgwDPYonrtkB6GSQ)
Content-id: <Pine.LNX.4.58.0403201443340.20651@portland.hansa.lan>
Content-type: TEXT/plain; charset=US-ASCII; name=bmac_mac.diff
Content-transfer-encoding: 7BIT
Content-disposition: attachment; filename=bmac_mac.diff
Content-description: 

--- linux.orig/drivers/net/bmac.c
+++ linux/drivers/net/bmac.c
@@ -1312,10 +1312,6 @@ static int __devinit bmac_probe(struct m
 	bmwrite(dev, INTDISABLE, DisableAll);

 	rev = addr[0] == 0 && addr[1] == 0xA0;
-	for (j = 0; j < 6; ++j) {
-		dev->dev_addr[j] = rev? bitrev(addr[j]): addr[j];
-		printk("%c%.2x", (j? ':': ' '), dev->dev_addr[j]);
-	}

 	/* Enable chip without interrupts for now */
 	bmac_enable_and_reset_chip(dev);
@@ -1380,6 +1376,10 @@ static int __devinit bmac_probe(struct m
 	}

 	printk(KERN_INFO "%s: BMAC%s at", dev->name, (is_bmac_plus? "+": ""));
+	for (j = 0; j < 6; ++j) {
+		dev->dev_addr[j] = rev? bitrev(addr[j]): addr[j];
+		printk("%c%.2x", (j? ':': ' '), dev->dev_addr[j]);
+	}
 	XXDEBUG((", base_addr=%#0lx", dev->base_addr));
 	printk("\n");


--Boundary_(ID_Azwbs0bgwDPYonrtkB6GSQ)--

** Sent via the linuxppc-dev mail list. See http://lists.linuxppc.org/
