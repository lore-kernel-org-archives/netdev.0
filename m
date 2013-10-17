From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: record rx queue for LRO packets
Date: Thu, 17 Oct 2013 15:43:10 -0400 (EDT)
Message-ID: <20131017.154310.1867265443770809407.davem@davemloft.net>
References: <1381612114.3392.14.camel@edumazet-glaptop.roam.corp.google.com>
	<504C9EFCA2D0054393414C9CB605C37F20DD4605@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	eilong@broadcom.com, willemb@google.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756787Ab3JQTnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:43:12 -0400
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20DD4605@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sun, 13 Oct 2013 06:23:31 +0000

>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Eric Dumazet
>> Sent: Sunday, October 13, 2013 12:09 AM
>> To: David Miller
>> Cc: netdev; Eilon Greenstein; Willem de Bruijn
>> Subject: [PATCH] bnx2x: record rx queue for LRO packets
>> 
>> From: Eric Dumazet <edumazet@google.com>
>> 
>> RPS support is kind of broken on bnx2x, because only non LRO packets get
>> proper rx queue information. This triggers reorders, as it seems bnx2x like to
>> generate a non LRO packet for segment including TCP PUSH flag : (this might
>> be pure coincidence, but all the reorders I've seen involve segments with a
>> PUSH)
>> 
>> 11:13:34.335847 IP A > B: . 415808:447136(31328) ack 1 win 457
>> <nop,nop,timestamp 3789336 3985797>
>> 11:13:34.335992 IP A > B: . 447136:448560(1424) ack 1 win 457
>> <nop,nop,timestamp 3789336 3985797>
>> 11:13:34.336391 IP A > B: . 448560:479888(31328) ack 1 win 457
>> <nop,nop,timestamp 3789337 3985797>
>> 11:13:34.336425 IP A > B: P 511216:512640(1424) ack 1 win 457
>> <nop,nop,timestamp 3789337 3985798>
>> 11:13:34.336423 IP A > B: . 479888:511216(31328) ack 1 win 457
>> <nop,nop,timestamp 3789337 3985798>
>> 11:13:34.336924 IP A > B: . 512640:543968(31328) ack 1 win 457
>> <nop,nop,timestamp 3789337 3985798>
>> 11:13:34.336963 IP A > B: . 543968:575296(31328) ack 1 win 457
>> <nop,nop,timestamp 3789337 3985798>
>> 
>> We must call skb_record_rx_queue() to properly give to RPS (and more
>> generally for TX queue selection on forward path) the receive queue
>> information.
>> 
>> Similar fix is needed for skb_mark_napi_id(), but will be handled in a
>> separate patch to ease stable backports.
>> 
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Acked-by: Dmitry Kravkov <dmitry@broadcom.com>
> 

Applied, thanks everyone.
