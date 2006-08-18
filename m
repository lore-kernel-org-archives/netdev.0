From: Vasily Averin <vvs@sw.ru>
Subject: [PATCH] e1000: ring buffers resources cleanup
Date: Fri, 18 Aug 2006 19:23:43 +0400
Message-ID: <44E5DB7F.4040205@sw.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090301000203040009090007"
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:8498 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1751398AbWHRPXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 11:23:36 -0400
To: netdev@vger.kernel.org, Jeb Cramer <cramerj@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>,
	devel@openvz.org, e1000-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090301000203040009090007
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

irq leak was found in 2.6.18-rc4 and e1000 7.2.7 from sourceforge:
if e1000_up fails in e1000_open() we do not free allocated irq

Signed-off-by: Vasily Averin <vvs@sw.ru>

Thank you,
	Vasily Averin
SWsoft Virtuozzo/OpenVZ Linux kernel team

--------------090301000203040009090007
Content-Type: text/plain;
 name="diff-e1000-irqleak-20060818"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="diff-e1000-irqleak-20060818"

--- linux-2.6.18-rc4/drivers/net/e1000/e1000_main.c.oirq	2006-08-18 18:53:05.000000000 +0400
+++ linux-2.6.18-rc4/drivers/net/e1000/e1000_main.c	2006-08-18 19:18:22.000000000 +0400
@@ -1208,7 +1208,7 @@ e1000_open(struct net_device *netdev)
 
 	err = e1000_request_irq(adapter);
 	if (err)
-		goto err_up;
+		goto err_req_irq;
 
 	e1000_power_up_phy(adapter);
 
@@ -1229,6 +1229,8 @@ e1000_open(struct net_device *netdev)
 	return E1000_SUCCESS;
 
 err_up:
+	e1000_free_irq(adapter);
+err_req_irq:
 	e1000_free_all_rx_resources(adapter);
 err_setup_rx:
 	e1000_free_all_tx_resources(adapter);

--------------090301000203040009090007--
