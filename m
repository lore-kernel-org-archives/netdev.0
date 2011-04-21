From: Marco Chiappero <marco@absence.it>
Subject: Re: rfkill-input to be removed
Date: Thu, 21 Apr 2011 15:47:50 +0200
Message-ID: <4DB03586.3040702@absence.it>
References: <4DAFEAA7.5090003@absence.it>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080006070303090702000809"
Cc: johannes@sipsolutions.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa013-1msr.fastwebnet.it ([62.101.93.133]:33995 "EHLO
	aa013-1msr.fastwebnet.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab1DUNrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 09:47:52 -0400
In-Reply-To: <4DAFEAA7.5090003@absence.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080006070303090702000809
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Il 21/04/2011 10:28, Marco Chiappero ha scritto:
> Please remove that code as soon as possible, rfkill input events should
> be handled by user space tools.

About this topic, I've created a patch right now, you can find it here:
http://www.absence.it/vaio-acpi/source/patches/rfkill-input.patch
Does it look fine?

Moreover, using checkpatch.pl I've found 3 coding style errors, I'm 
attaching a patch to fix them (apply this one first).

And just one last thing: as there is no configuration option inside the 
menu, shouldn't we change the "menuconfig RFKILL" line to "config 
RFKILL" inside net/rfkill/Kconfig?

--------------080006070303090702000809
Content-Type: text/x-patch;
 name="rfkill-style.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rfkill-style.patch"

Signed-off-by: Marco Chiappero <marco@absence.it>
--- a/net/rfkill/core.c	2011-04-19 06:26:00.000000000 +0200
+++ b/net/rfkill/core.c	2011-04-21 15:33:21.970094489 +0200
@@ -621,7 +621,7 @@ static ssize_t rfkill_hard_show(struct d
 {
 	struct rfkill *rfkill = to_rfkill(dev);
 
-	return sprintf(buf, "%d\n", (rfkill->state & RFKILL_BLOCK_HW) ? 1 : 0 );
+	return sprintf(buf, "%d\n", (rfkill->state & RFKILL_BLOCK_HW) ? 1 : 0);
 }
 
 static ssize_t rfkill_soft_show(struct device *dev,
@@ -630,7 +630,7 @@ static ssize_t rfkill_soft_show(struct d
 {
 	struct rfkill *rfkill = to_rfkill(dev);
 
-	return sprintf(buf, "%d\n", (rfkill->state & RFKILL_BLOCK_SW) ? 1 : 0 );
+	return sprintf(buf, "%d\n", (rfkill->state & RFKILL_BLOCK_SW) ? 1 : 0);
 }
 
 static ssize_t rfkill_soft_store(struct device *dev,
@@ -648,7 +648,7 @@ static ssize_t rfkill_soft_store(struct 
 	if (err)
 		return err;
 
-	if (state > 1 )
+	if (state > 1)
 		return -EINVAL;
 
 	mutex_lock(&rfkill_global_mutex);

--------------080006070303090702000809--
