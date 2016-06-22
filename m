From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: unclone unbundled buffers before
 forwarding
Date: Wed, 22 Jun 2016 16:34:07 -0400 (EDT)
Message-ID: <20160622.163407.1179660044612083904.davem@davemloft.net>
References: <1466428846-12334-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbcFVUeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 16:34:13 -0400
In-Reply-To: <1466428846-12334-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon, 20 Jun 2016 09:20:46 -0400

> When extracting an individual message from a received "bundle" buffer,
> we just create a clone of the base buffer, and adjust it to point into
> the right position of the linearized data area of the latter. This works
> well for regular message reception, but during periods of extremely high
> load it may happen that an extracted buffer, e.g, a connection probe, is
> reversed and forwarded through an external interface while the preceding
> extracted message is still unhandled. When this happens, the header or
> data area of the preceding message will be partially overwritten by a
> MAC header, leading to unpredicatable consequences, such as a link
> reset.
> 
> We now fix this by ensuring that the msg_reverse() function never
> returns a cloned buffer, and that the returned buffer always contains
> sufficient valid head and tail room to be forwarded.
> 
> Reported-by: Erik Hugne <erik.hugne@gmail.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.
