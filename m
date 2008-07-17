From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH RFC 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Thu, 17 Jul 2008 14:33:33 +0300
Message-ID: <20080717143333.188544nw52n0v6dc@hayate.ip6>
References: <20080717100921.3327.3324.stgit@fate.lan>
	<20080717100933.3327.20158.stgit@fate.lan> <487F1AD2.10208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:48382 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043AbYGQLdf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 07:33:35 -0400
In-Reply-To: <487F1AD2.10208@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Patrick McHardy" <kaber@trash.net>:

> Jussi Kivilinna wrote:
>> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
>> ---
>>
>> include/net/sch_generic.h |   17 +++++++++++------
>> net/sched/sch_atm.c       |    4 ++--
>> net/sched/sch_cbq.c       |   14 ++++++--------
>> net/sched/sch_dsmark.c    |    2 +-
>> net/sched/sch_fifo.c      |    2 +-
>> net/sched/sch_gred.c      |   12 ++++++------
>> net/sched/sch_hfsc.c      |   14 ++++++--------
>> net/sched/sch_htb.c       |    9 +++++----
>> net/sched/sch_netem.c     |    6 +++---
>> net/sched/sch_prio.c      |    2 +-
>> net/sched/sch_red.c       |    2 +-
>> net/sched/sch_sfq.c       |   16 ++++++++--------
>> net/sched/sch_tbf.c       |    9 ++++++---
>> net/sched/sch_teql.c      |    6 +++---
>> 14 files changed, 60 insertions(+), 55 deletions(-)
>>
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index e3b0d71..1f1de3b 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -258,6 +258,11 @@ static inline bool qdisc_tx_is_noop(const   
>> struct net_device *dev)
>> 	return (txq->qdisc == &noop_qdisc);
>> }
>> +static inline unsigned int qdisc_tx_len(struct sk_buff *skb)
>> +{
>> +	return skb->len;
>> +}
>
>
> Just one question - should this also be useable for ingress? If so
> a different name would make sense.
>
>

Yes, it should be. Police action has rate table that could be replaced  
with size table, so qdisc_pkt_len() would be better name.

  - Jussi

