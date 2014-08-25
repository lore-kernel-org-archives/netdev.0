From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Mon, 25 Aug 2014 16:34:58 -0700 (PDT)
Message-ID: <20140825.163458.1117073971092495452.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au, dborkman@redhat.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755221AbaHYXfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 19:35:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Given Jesper's performance numbers, it's not the way to go.

Instead, go with a signalling scheme via new boolean skb->xmit_more.

This has several advantages:

1) Nearly trivial driver support, just protect the tail pointer
   update with the skb->xmit_more check.

2) No extra indirect calls in the non-deferral cases.

Signed-off-by: David S. Miller <davem@davemloft.net>
