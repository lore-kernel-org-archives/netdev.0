From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: ixp4xx_hss: Little improvement in create_chan function
Date: Wed, 26 Nov 2008 18:38:10 +0100
Message-ID: <b0438a630811260938n14835453jda2da43c6f1445f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, "Krzysztof Halasa" <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:61321 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894AbYKZRiM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 12:38:12 -0500
Received: by yx-out-2324.google.com with SMTP id 8so286917yxm.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2008 09:38:10 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

We are searching for the desired channel three times in the same list.
So I think we could erase two of them. What do you think?

Signed-off-by: Miguel =C1ngel =C1lvarez (gotzoncabanes@gmail.com)
---
--- ixp4xx_hss.c.orig	2008-11-19 11:26:54.000000000 +0100
+++ ixp4xx_hss.c.create_chan	2008-11-26 18:34:23.000000000 +0100
@@ -2273,10 +2273,13 @@
 	}

 	for (ch =3D 0; ch < MAX_CHANNELS; ch++)
-		if (channels[ch] && port->channels[ch] !=3D CHANNEL_UNUSED) {
-			printk(KERN_DEBUG "Channel #%i already in use\n", ch);
-			err =3D -EBUSY;
-			goto free;
+		if (channels[ch]) {
+		 	if (port->channels[ch] !=3D CHANNEL_UNUSED) {
+				printk(KERN_DEBUG "Channel #%i already in use\n", ch);
+				err =3D -EBUSY;
+				goto free;
+			} else
+				break;
 		}

 	for (id =3D 0; id < MAX_CHAN_DEVICES; id++)
@@ -2288,10 +2291,6 @@
 		goto free;
 	}

-	for (ch =3D 0; ch < MAX_CHANNELS; ch++)
-		if (channels[ch])
-			break;
-
 	minor =3D port->id * MAX_CHAN_DEVICES + ch;
 	chan_dev->id =3D id;
 	chan_dev->port =3D port;
@@ -2307,9 +2306,7 @@
 	if ((err =3D cdev_add(&chan_dev->cdev, MKDEV(chan_major, minor), 1)))
 		goto destroy_device;

-	for (ch =3D 0; ch < MAX_CHANNELS; ch++)
-		if (channels[ch])
-			port->channels[ch] =3D id;
+	port->channels[ch] =3D id;
 	port->chan_devices[id] =3D chan_dev;
 	dev_set_drvdata(chan_dev->dev, chan_dev);
 	BUG_ON(device_create_file(chan_dev->dev, &chan_attr));

Thanks

Miguel =C1ngel =C1lvarez
