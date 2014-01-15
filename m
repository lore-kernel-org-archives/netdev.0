From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] tcp: delete redundant calls of tcp_mtup_init()
 and
Date: Tue, 14 Jan 2014 16:41:05 -0800 (PST)
Message-ID: <20140114.164105.524133214769947013.davem@davemloft.net>
References: <cover.1389513042.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbaAOAlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:41:08 -0500
In-Reply-To: <cover.1389513042.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Sun, 12 Jan 2014 15:54:29 +0800

> I find that both tcp_v4_syn_recv_sock() and tcp_v6_syn_recv_sock() call them
> for new sock, so delete redundant calls of them. 
> 
> Weiping Pan (2):
>   tcp: delete redundant calls of tcp_mtup_init()
>   tcp: delete redundant call of tcp_initialize_rcv_mss()

I do not agree with the approach of these two patches.

It is better to have tcp_rcv_state_process() (one location) make these
calls rather than each and every inet sock operations instance.

Therefore you should remove the calls from tcp_v{4,6}_recv_sock() and
keep the one in tcp_rcv_state_process().

Thanks.
