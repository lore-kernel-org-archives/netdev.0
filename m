From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/15] Pass keys down to ip_queue_xmit()
Date: Sun, 08 May 2011 15:37:18 -0700 (PDT)
Message-ID: <20110508.153718.226797622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755390Ab1EHWhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:37:51 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1FB7224C087
	for <netdev@vger.kernel.org>; Sun,  8 May 2011 15:37:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The final goal of this set of changes is to normalize all uses
of ip_queue_xmit() and how sockets are connected up so that
ip_queue_xmit() can elide it's usage of rt->rt_{src,dst}

Along the way I found some locking problems in L2TP fixed here.

Basically we reuse inet_sk->cork.fl to store keying information
and pass that (or something more appropriate) to ip_queue_xmit()

This opens up the door for SCTP to express exactly what is does, by
passing in a flow which is now added to the individual transport
instances.

Taking this one step further, we could add a "struct dst **dst"
argument to ->queue_xmit() and friends, then SCTP could pass in
"&transport->dst" and it would no longer need to do that special
"pre-hookup the DST to skb" uglyness.

L2TP could be modified similarly.

Then the pre-routed SKB code can be removed completely.

Signed-off-by: David S. Miller <davem@davemloft.net>
