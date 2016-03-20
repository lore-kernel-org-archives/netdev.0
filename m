From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: align MTU to a word
Date: Sun, 20 Mar 2016 16:31:56 -0400 (EDT)
Message-ID: <20160320.163156.385019913302887750.davem@davemloft.net>
References: <1458400640-25448-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131AbcCTUb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 16:31:58 -0400
In-Reply-To: <1458400640-25448-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Sat, 19 Mar 2016 12:17:20 -0300

> SCTP is a protocol that is aligned to a word (4 bytes). Thus using bare
> MTU can sometimes return values that are not aligned, like for loopback,
> which is 65536 but ipv4_mtu() limits that to 65535. This mis-alignment
> will cause the last non-aligned bytes to never be used and can cause
> issues with congestion control.
> 
> So it's better to just consider a lower MTU and keep congestion control
> calcs saner as they are based on PMTU.
> 
> Same applies to icmp frag needed messages, which is also fixed by this
> patch.
> 
> One other effect of this is the inability to send MTU-sized packet
> without queueing or fragmentation and without hitting Nagle. As the
> check performed at sctp_packet_can_append_data():
> 
> if (chunk->skb->len + q->out_qlen >= transport->pathmtu - packet->overhead)
> 	/* Enough data queued to fill a packet */
> 	return SCTP_XMIT_OK;
> 
> with the above example of MTU, if there are no other messages queued,
> one cannot send a packet that just fits one packet (65532 bytes) and
> without causing DATA chunk fragmentation or a delay.
> 
> v2:
>  - Added WORD_TRUNC macro
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied.
