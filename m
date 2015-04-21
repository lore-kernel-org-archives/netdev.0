From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: Fix "hw csum failure" message flood
 for ppp tunnel
Date: Mon, 20 Apr 2015 22:01:44 -0400 (EDT)
Message-ID: <20150420.220144.784138484983756987.davem@davemloft.net>
References: <1429564205-1661247-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbbDUCBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 22:01:48 -0400
In-Reply-To: <1429564205-1661247-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 20 Apr 2015 14:10:03 -0700

> This patch set addresses bug "Bug 95171 - "hw csum failure" message
> flood for ppp tunnel since upgrade to 3.16". The problem is that pppoe
> is being used over UDP with UDP checksusm enabled. On receive
> checksum conversion turns checksum-unnecessary in checksum-
> complete. The PPP receive functions do no properly pull
> the checksum over its headers, so that when an encapsulated
> checksums is considered the checksum-complete value is incorrect.
> 
> This patch adds skb_checksum_complete_unset which can be called
> in the receive path in lieu of pulling checksum complete in
> layer. This is useful when the packet is being modified (e.g.
> decompressed) and the checksum-complete value is no longer
> relevant.
> 
> In the ppp_receive_frame we call skb_checksum_complete_unset to toss
> out checksum-complete. This should eliminate the reported messages.
> Alternatively, we could add skb_postpull_rcsum and probably
> special case handling for VJ compression if maintaining the
> checksum-complete is needed (not clear to me this is worth the
> effort).
> 
> I haven't tested this since setting up the failure scenario doesn't
> seem trivial to configure.

I'm preemptively applying this, but it's really important for
folks to give this some good testing.

Thanks Tom.
