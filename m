From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] tcp: fastopen: fix rcv_wup initialization for TFO
 server on SYN/data
Date: Thu, 01 Sep 2016 16:40:35 -0700 (PDT)
Message-ID: <20160901.164035.1179448299997912522.davem@davemloft.net>
References: <1472572523-10449-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com,
        soheil@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753106AbcIAXkf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 19:40:35 -0400
In-Reply-To: <1472572523-10449-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Tue, 30 Aug 2016 11:55:23 -0400

> Yuchung noticed that on the first TFO server data packet sent after
> the (TFO) handshake, the server echoed the TCP timestamp value in the
> SYN/data instead of the timestamp value in the final ACK of the
> handshake. This problem did not happen on regular opens.
> 
> The tcp_replace_ts_recent() logic that decides whether to remember an
> incoming TS value needs tp->rcv_wup to hold the latest receive
> sequence number that we have ACKed (latest tp->rcv_nxt we have
> ACKed). This commit fixes this issue by ensuring that a TFO server
> properly updates tp->rcv_wup to match tp->rcv_nxt at the time it sends
> a SYN/ACK for the SYN/data.
> 
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Fixes: 168a8f58059a ("tcp: TCP Fast Open Server - main code path")

Applied to 'net', thanks.
