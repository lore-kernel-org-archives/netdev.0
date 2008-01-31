From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 6/6] [TCP]: Reorganize struct tcp_sock to save 16 bytes
	on 64-bit arch
Date: Thu, 31 Jan 2008 18:17:20 -0200
Message-ID: <20080131201720.GE11940@ghostprotocols.net>
References: <1201804304-28777-1-git-send-email-acme@redhat.com> <1201804304-28777-2-git-send-email-acme@redhat.com> <1201804304-28777-3-git-send-email-acme@redhat.com> <1201804304-28777-4-git-send-email-acme@redhat.com> <1201804304-28777-5-git-send-email-acme@redhat.com> <1201804304-28777-6-git-send-email-acme@redhat.com> <1201804304-28777-7-git-send-email-acme@redhat.com> <47A22841.6090508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60474 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753996AbYAaURv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 15:17:51 -0500
Content-Disposition: inline
In-Reply-To: <47A22841.6090508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jan 31, 2008 at 08:57:53PM +0100, Eric Dumazet escreveu:
> Arnaldo Carvalho de Melo a =E9crit :
>> /home/acme/git/net-2.6/net/ipv6/tcp_ipv6.c:
>>   struct tcp_sock  |  -16
>>   struct tcp6_sock |  -16
>>  2 structs changed
>>
>> Now it is at:
>>
>> /* size: 1552, cachelines: 25 */
>> /* paddings: 2, sum paddings: 8 */
>> /* last cacheline: 16 bytes */
>>
>> As soon as we stop using skb_queue_list we'll get it down to 24 cach=
elines.
>>
>> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
>> ---
>>  include/linux/tcp.h |    6 ++++--
>>  1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
>> index 08027f1..f48644d 100644
>> --- a/include/linux/tcp.h
>> +++ b/include/linux/tcp.h
>> @@ -304,7 +304,6 @@ struct tcp_sock {
>>  	u32	rtt_seq;	/* sequence number to update rttvar	*/
>>   	u32	packets_out;	/* Packets which are "in flight"	*/
>> -	u32	retrans_out;	/* Retransmitted packets out		*/
>>  /*
>>   *      Options received (usually on last packet, some only on SYN =
packets).
>>   */
>> @@ -332,6 +331,8 @@ struct tcp_sock {
>>   	struct tcp_sack_block recv_sack_cache[4];
>>  +	u32	retrans_out;	/* Retransmitted packets out		*/
>> +
>
> Hum... retrans_out should sit close to packets_out (or lost_out/sacke=
d_out=20
> ???), please.
>
> 'struct tcp_sock' is very large on 64 bits, so I would prefer to make=
 sure=20
> most paths dont need to touch all 24 cache lines (or 25 cache lines).

That is perfectly fine, I'll replace my patch with another, that states
this beyond doubt.

- Arnaldo
