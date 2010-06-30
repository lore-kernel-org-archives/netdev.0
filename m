From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: TCP not triggering a fast retransmit?
Date: Wed, 30 Jun 2010 16:10:10 -0700
Message-ID: <3E6E92D2-B053-4E43-B2D8-C09701CBC923@earthlink.net>
References: <AANLkTinJC6uS1GTbKJWL9AlEs2e5GleQvJbTUZrsQHaE@mail.gmail.com> <1277931829.4878.9.camel@localhost> <20100630.142256.77345240.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, novickivan@gmail.com,
	netdev@vger.kernel.org, jmatthews@greenplum.com,
	theath@greenplum.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:46732 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754179Ab0F3XKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 19:10:22 -0400
In-Reply-To: <20100630.142256.77345240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 30, 2010, at 2:22 PM, David Miller wrote:

> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 30 Jun 2010 22:03:49 +0100
> 
>> In that packet capture I see TCP payload lengths which are 2, 3 and 4
>> times the usual MSS of 1448 bytes, which implies that GRO or LRO is in
>> use.  In RHEL 5.4 the TCP stack does not ACK often enough in this case
>> because it is missing this change:
>> 
>> commit ff9b5e0f08cb650d113eef0c654f931c0a7ae730
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Thu Aug 31 15:11:02 2006 -0700
>> 
>>    [TCP]: Fix rcv mss estimate for LRO
> 
> It certainly could be, I'll try make sure this gets rectified,
> thanks!
> --

Guys,

	I think you suggesting that:

__tcp_ack_snd_chk() within tcp_input.c needs: 
an ABC (Appropriate Byte Counting) Allman type check
where the frame rcv'd computed size is 2x or larger
(and no out of order queue) , then

even if NOT in quickack mode, needs to be ACKed,
with tcp_send_ack()

and if in quickack mode, needs a mss incr seq number of ACKs where
number of ACKs equals the number of the multiple of mss

Note: without incrementing the SEQ between ACKs, it would result in
a DupACK at the other end system,

Correct?

Mitchell Erblich


> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

