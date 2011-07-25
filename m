From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 0/2] pktgen: Clone skb to avoid corruption of skbs in ndo_start_xmit methods (v2)
Date: Mon, 25 Jul 2011 15:45:18 -0400
Message-ID: <1311623120-26839-1-git-send-email-nhorman@tuxdriver.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44794 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217Ab1GYTpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 15:45:39 -0400
Received: from hmsreliant.think-freely.org ([2001:470:8:a08:7aac:c0ff:fec2:933b] helo=localhost)
	by smtp.tuxdriver.com with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.63)
	(envelope-from <nhorman@tuxdriver.com>)
	id 1QlR5j-0000LP-QW
	for netdev@vger.kernel.org; Mon, 25 Jul 2011 15:45:38 -0400
In-Reply-To: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, after considering all your comments, Dave suggested this as an alternate
approach:

1) We create a new priv_flag, IFF_SKB_TX_SHARED, to identify drivers capable of
handling shared skbs.  Default is to not set this flag

2) Modify ether_setup to enable this flag, under the assumption that any driver
calling this  function is initalizing a real ethernet device and as such can
handle shared skbs since they don't tend to store state in the skb struct.
Pktgen can then query this flag when a user script attempts to issue the
clone_skb command and decide if it is to be alowed or not.

3) Audit the network drivers calling ether_setup to identify any code doing so
that can't actualy handle shared skbs and manually disable the new flag.  There
are about 10 drivers in this category.

Thoughts/reviews aprpeciated.
Neil
 
