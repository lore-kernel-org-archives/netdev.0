From: "Suresh, Charles" <Charles.Suresh@amd.com>
Subject: __kfree_skb eventually calls kfree_skb violating dropwatch
 assumption
Date: Wed, 12 Oct 2011 21:25:10 -0500
Message-ID: <27F465BDABE6954AABB2A4E3599BDAC702AD1DC3AB@sausexmbp02.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@redhat.com" <nhorman@redhat.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:36424
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752375Ab1JMCZW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 22:25:22 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree_skb can be called from __kfree_skb through the following call chain :

kfree_skb  <- skb_drop_list <- skb_drop_fraglist <- skb_release_data <-  skb_release_all <- __kfree_skb (on the 2.38.4 kernel).

This violates the assumption in the dropwatch tool that discarded packets go through the kfree_skb path and all others must go through the consume_skb path (thus resulting in the over-counting of discarded packets in dropwatch).

Neil Horman the author of dropwatch suggested that this could be fixed by skb_drop_list calling consume_skb instead of kfree_skb.

Charles
