From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Optimize corking further.
Date: Fri, 06 May 2011 15:26:18 -0700 (PDT)
Message-ID: <20110506.152618.245398453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37679
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753136Ab1EFW0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 18:26:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


For the on-stack corking case, we initialize the inet_cork twice.
Furthermore the paths that inspect the inet_cork in ip_output.c
do not care at all about the flow which is large.

Split inet_cork up and optimize the initialization in the on-stack
case.

Results for "udpflood -l 10000000 ${IP_ADDR}" on Niagara2+ @ 1.2GHz

Before	1m45s
After	1m40s

Signed-off-by: David S. Miller <davem@davemloft.net>
