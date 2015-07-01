From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bail on sock_wfree, sock_rfree when we
 have a TCP_TIMEWAIT sk
Date: Wed, 01 Jul 2015 14:14:02 -0700 (PDT)
Message-ID: <20150701.141402.587634025761326092.davem@davemloft.net>
References: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, kernel-team@fb.com
To: agartrell@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbbGAVOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2015 17:14:04 -0400
In-Reply-To: <1435781589-2210146-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Gartrell <agartrell@fb.com>
Date: Wed, 1 Jul 2015 13:13:09 -0700

> If we early-demux bind a TCP_TIMEWAIT socket to an skb and then orphan it
> (as we need to do in the ipvs forwarding case), sock_wfree and sock_rfree
> are going to reach into the inet_timewait_sock and mess with fields that
> don't exist.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>

If we're forwarding, we should not find a local socket, period.

We should only match sockets for locally destined packets.

So I'd say that the state in which you say this can occur is illegal.
