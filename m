From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/4] Diet struct sk_buff a bit
Date: Fri, 19 Oct 2007 12:59:17 +0400
Message-ID: <471871E5.7060900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35277 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbXJSI73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 04:59:29 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The __u16 queue_mapping field only makes sense in the
CONFIG_NETDEVICES_MULTIQUEUE=y case only.

Despite this field may be set explicitly to some non-zero 
value (in net/core/pktgen.c), the exact value affects 
nothing in case the config option in question is N (mainly 
it is used in netif_subqueue_stopped(), which will always
return 0 in this case).

So cleanup the code a bit and move this field under the
config option.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
