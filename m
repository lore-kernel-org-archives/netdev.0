From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: also point GSO head_skb to the sk when
 it's available
Date: Mon, 25 Jul 2016 11:25:01 -0700 (PDT)
Message-ID: <20160725.112501.2010684051493485788.davem@davemloft.net>
References: <aa37c8d65d8d304be73f6c237202760978ec124f.1469244494.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbcGYSZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 14:25:02 -0400
In-Reply-To: <aa37c8d65d8d304be73f6c237202760978ec124f.1469244494.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Sat, 23 Jul 2016 00:33:44 -0300

> The head skb for GSO packets won't travel through the inner depths of
> SCTP stack as it doesn't contain any chunks on it. That means skb->sk
> doesn't get set and then when sctp_recvmsg() calls
> sctp_inet6_skb_msgname() on the head_skb it panics, as this last needs
> to check flags at the socket (sp->v4mapped).
> 
> The fix is to initialize skb->sk for th head skb once we are able to do
> it. That is, when the first chunk is processed.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
