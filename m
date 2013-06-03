From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH v2] include/linux/skbuff.h: using '(u16) ~0U' instead
 of '~0U'
Date: Mon, 03 Jun 2013 19:46:08 +0800
Message-ID: <51AC8200.50205@asianux.com>
References: <51A6EBC5.7040601@asianux.com> <CAHp75VfWvXkaoYQ_40idSsLYUA=YqaswnV2y-hODHjt7JMHQvQ@mail.gmail.com> <51AC60AA.8010107@asianux.com> <CAHp75Vc19Kii7_TF+9aF4ZeKAa4_92DCVL+u1duZDTu38o2qsw@mail.gmail.com> <51AC7546.4010002@asianux.com> <51AC7CD4.2060801@asianux.com> <CAHp75VdSFRO2T_2Z1cVw_2Frk5MNLUBKd+p8S1sw_MBM+pyu=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, Pravin Shelar <pshelar@nicira.com>,
	Mel Gorman <mgorman@suse.de>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:27968 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755503Ab3FCLrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 07:47:00 -0400
In-Reply-To: <CAHp75VdSFRO2T_2Z1cVw_2Frk5MNLUBKd+p8S1sw_MBM+pyu=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2013 07:34 PM, Andy Shevchenko wrote:
>> --- a/include/linux/skbuff.h
>> > +++ b/include/linux/skbuff.h
>> > @@ -40,6 +40,8 @@
>> >  #define CHECKSUM_COMPLETE 2
>> >  #define CHECKSUM_PARTIAL 3
>> >
>> > +#define SKB_HEADER_UNSET_16    ((unsigned short) ~0U)
> Isn't better to use the same type as used in the structure description?
> 

It sounds reasonable, I will wait 1 days, if no additional suggestions
or completions, I will send patch v3.


>> > --- a/net/core/skbuff.c
>> > +++ b/net/core/skbuff.c
>> > @@ -200,7 +200,8 @@ struct sk_buff *__alloc_skb_head(gfp_t gfp_mask, int node)
>> >         atomic_set(&skb->users, 1);
>> >
>> >  #ifdef NET_SKBUFF_DATA_USES_OFFSET
>> > -       skb->mac_header = (__u16) ~0U;
>> > +       skb->mac_header = SKB_HEADER_UNSET_16;
>> > +       skb->transport_header = SKB_HEADER_UNSET_16;
> Is it correct to assign transport_header here as well?

At least, it is correct: they are in the same structure, and almost a
neighbor with each other.

Hmm... I guess that may be useless currently which will waste one
instruction.

But I still suggest to add it, it can avoid the new mistakes in the future.

Welcome another members to provide their suggestions for it.


Thanks.
-- 
Chen Gang

Asianux Corporation
