From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: better retrans tracking for defer-accept
Date: Sat, 03 Nov 2012 14:46:59 -0400 (EDT)
Message-ID: <20121103.144659.41045577384221098.davem@davemloft.net>
References: <alpine.LFD.2.00.1210271556250.1628@ja.ssi.bg>
	<1351344725.30380.286.camel@edumazet-glaptop>
	<1351347537.30380.315.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	ncardwell@google.com, venkat.x.venkatsubra@oracle.com,
	enh@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab2KCSrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 14:47:02 -0400
In-Reply-To: <1351347537.30380.315.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 27 Oct 2012 16:18:57 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> For passive TCP connections using TCP_DEFER_ACCEPT facility,
> we incorrectly increment req->retrans each time timeout triggers
> while no SYNACK is sent.
> 
> SYNACK are not sent for TCP_DEFER_ACCEPT that were established (for wich
> we received the ACK from client). Only the last SYNACK is
> sent so that we can receive again an ACK from client, to move the
> req into accept queue. We plan to change this later to avoid
> the useless retransmit (and potential problem as this SYNACK could be
> lost)
> 
> TCP_INFO later gives wrong information to user, claiming imaginary
> retransmits.
> 
> Decouple req->retrans field into two independent fields :
> 
> num_retrans : number of retransmit
> num_timeout : number of timeouts
> 
> num_timeout is the counter that is incremented at each timeout,
> regardless of actual SYNACK being sent or not, and used to
> compute the exponential timeout.
> 
> Introduce inet_rtx_syn_ack() helper to increment num_retrans
> only if ->rtx_syn_ack() succeeded.
> 
> Use inet_rtx_syn_ack() from tcp_check_req() to increment num_retrans
> when we re-send a SYNACK in answer to a (retransmitted) SYN.
> Prior to this patch, we were not counting these retransmits.
> 
> Change tcp_v[46]_rtx_synack() to increment TCP_MIB_RETRANSSEGS
> only if a synack packet was successfully queued.
> 
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
