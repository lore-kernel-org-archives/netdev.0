From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Wed, 08 Aug 2007 01:09:40 +0200
Message-ID: <87ps1zgcwb.fsf@p4.be.48ers.dk>
References: <OF5F9C7C7D.04B8DBCD-ON80257328.0063528D-80257328.0065CB53@smsc.com>
	<87hcnioppf.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bahadir Balban <Bahadir.Balban@arm.com>,
	Bill Gatliff <bgat@billgatliff.com>,
	Dustin Mcintire <dustin@sensoria.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.mobistarmail.be ([193.252.23.61]:9384 "EHLO
	smtp40.mobistarmail.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757410AbXHGXIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 19:08:42 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf4017.mobistarmail.be (SMTP Server) with ESMTP id 7664A700008F
	for <netdev@vger.kernel.org>; Wed,  8 Aug 2007 01:08:38 +0200 (CEST)
In-Reply-To: <87hcnioppf.fsf@p4.be.48ers.dk> (Peter Korsgaard's message of
	"Thu, 02 Aug 2007 00:27:40 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Peter" == Peter Korsgaard <jacmet@sunsite.dk> writes:

Hi,

 Peter> I'll give your driver a try and report back.

Ok, the driver seems to be working (after fixing up the accessor
routines for my hw setup) and performance is comparable to Dustin's
driver.

It would be nice if the driver would enable the byte swapping support
in the hw if it detects the wrong endian - Like this:

Index: linux/drivers/net/smsc911x.c
===================================================================
--- linux.orig/drivers/net/smsc911x.c
+++ linux/drivers/net/smsc911x.c
@@ -1787,6 +1787,13 @@
 		return -ENODEV;
 	}
 
+	/* check endian */
+	if (smsc911x_reg_read(pdata, BYTE_TEST) == 0x43218765) {
+		SMSC_TRACE("Byte test looks swapped, inverting");
+		smsc911x_reg_write(~smsc911x_reg_read(pdata, ENDIAN),
+				   pdata, ENDIAN);
+	}
+
 	/* Default generation to zero (all workarounds apply) */
 	pdata->generation = 0;

-- 
Bye, Peter Korsgaard

