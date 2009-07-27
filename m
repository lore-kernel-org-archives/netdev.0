From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Mon, 27 Jul 2009 15:35:48 -0700
Message-ID: <20090727153548.7c0d9f85@nehalam>
References: <4A65EC3F.4050400@gibraltar.at>
	<20090723102848.00a56ad1@nehalam>
	<4A6D8975.4050000@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42502 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754645AbZG0WiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 18:38:14 -0400
In-Reply-To: <4A6D8975.4050000@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does this help?

--- a/drivers/net/sky2.c	2009-07-27 15:28:27.653757064 -0700
+++ b/drivers/net/sky2.c	2009-07-27 15:34:24.358730966 -0700
@@ -2763,6 +2763,11 @@ static int sky2_poll(struct napi_struct 
 	int work_done = 0;
 	u16 idx;
 
+	if (unlikely(status == ~0)) {
+		dev_info(&hw->pdev->dev, "device status error\n");
+		goto clear_napi;
+	}
+
 	if (unlikely(status & Y2_IS_ERROR))
 		sky2_err_intr(hw, status);
 
@@ -2779,6 +2784,7 @@ static int sky2_poll(struct napi_struct 
 			goto done;
 	}
 
+clear_napi:
 	napi_complete(napi);
 	sky2_read32(hw, B0_Y2_SP_LISR);
 done:
