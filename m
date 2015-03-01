From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 3/6] flow_dissector: Add hash_extra field to
 flow_keys struct
Date: Sun, 1 Mar 2015 09:55:07 -0800
Message-ID: <CA+mtBx8zP0rDG1Dh=KcG0t5dqaqnqS+8---4SBvLD_jGpgue2g@mail.gmail.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
	<1425093109-1077-4-git-send-email-therbert@google.com>
	<1425109054.5130.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150228203119.GA7687@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:46340 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603AbbCARzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 12:55:08 -0500
Received: by igbhl2 with SMTP id hl2so11918657igb.5
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2015 09:55:07 -0800 (PST)
In-Reply-To: <20150228203119.GA7687@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 28, 2015 at 12:31 PM, Florian Westphal <fw@strlen.de> wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2015-02-27 at 19:11 -0800, Tom Herbert wrote:
>>
>> > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> > index c605d30..d41a034 100644
>> > --- a/include/net/sch_generic.h
>> > +++ b/include/net/sch_generic.h
>> > @@ -252,7 +252,7 @@ struct qdisc_skb_cb {
>> >     unsigned int            pkt_len;
>> >     u16                     slave_dev_queue_mapping;
>> >     u16                     _pad;
>> > -#define QDISC_CB_PRIV_LEN 20
>> > +#define QDISC_CB_PRIV_LEN 24
>> >     unsigned char           data[QDISC_CB_PRIV_LEN];
>> >  };
>> >
>>
>> This change breaks kernel build : We already are at the cb[] limit.
>>
>> Please check commit 257117862634d89de33fec74858b1a0ba5ab444b
>> ("net: sched: shrink struct qdisc_skb_cb to 28 bytes")
>
> I've been toying around with reducing skb->cb[] to 44 bytes,
> Seems Tom could integrate following patch from my test branch:
>
> http://git.breakpoint.cc/cgit/fw/net-next.git/commit/?h=skb_cb_44_01&id=29d711e1a71244b71940c2d1e346500bef4d6670
>
> It makes sfq use a smaller flow key state.

Alternatively, I think we might be able to eliminate the use of
flow_keys and flow_dissect from the qdisc code altogether. It looks
like this is only being used to determine a hash over the addresses,
ports, and protocol so I am thinking that we can just call
skb_get_hash for that. Will try to post some patches soon.
