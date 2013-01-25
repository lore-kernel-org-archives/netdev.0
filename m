From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/2] net: Add skb_unclone() helper function.
Date: Thu, 24 Jan 2013 17:36:26 -0800
Message-ID: <CALnjE+rJdddCLZ8+30u8yWPx8xJtRv-+XQgDX1CQvecgOHE5fg@mail.gmail.com>
References: <1359065787-1763-1-git-send-email-pshelar@nicira.com>
	<CAHXqBF+uHoGRXP3HdiL2Zm9RUhT-+7RsrRhAYZyEg-FjzH2-eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jesse@nicira.com, eric.dumazet@gmail.com
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:53812 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750970Ab3AYBg2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 20:36:28 -0500
Received: by mail-qc0-f199.google.com with SMTP id b14so9371949qcs.10
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 17:36:26 -0800 (PST)
In-Reply-To: <CAHXqBF+uHoGRXP3HdiL2Zm9RUhT-+7RsrRhAYZyEg-FjzH2-eQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 5:21 PM, Micha=C5=82 Miros=C5=82aw <mirqus@gmai=
l.com> wrote:
> 2013/1/24 Pravin B Shelar <pshelar@nicira.com>:
> [...]
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -798,6 +798,19 @@ static inline int skb_cloned(const struct sk_bu=
ff *skb)
>>  }
>>
>>  /**
>> + *     skb_unclone - creates separate copy if skb is cloned.
>> + */
>> +static inline bool skb_unclone(struct sk_buff *skb, gfp_t pri)
>> +{
>> +       might_sleep_if(pri & __GFP_WAIT);
>> +
>> +       if (skb_cloned(skb))
>> +               return pskb_expand_head(skb, 0, 0, pri);
>> +
>> +       return 0;
>> +}
>
> This should return int. pskb_expand_head() returns 0 or -ENOMEM.
>
> [...]
>> diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunn=
el.c
>> index ddee0a0..c1f00ef 100644
>> --- a/net/ipv4/xfrm4_mode_tunnel.c
>> +++ b/net/ipv4/xfrm4_mode_tunnel.c
>> @@ -142,8 +142,7 @@ static int xfrm4_mode_tunnel_input(struct xfrm_s=
tate *x, struct sk_buff *skb)
>>         for_each_input_rcu(rcv_notify_handlers, handler)
>>                 handler->handler(skb);
>>
>> -       if (skb_cloned(skb) &&
>> -           (err =3D pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
>> +       if (skb_unclone(skb, GFP_ATOMIC))
>>                 goto out;
>
> And here return -ENOMEM is replaced with return -EINVAL because of th=
is.
>
ok, I will change skb_unclone return to int.

Thanks.
