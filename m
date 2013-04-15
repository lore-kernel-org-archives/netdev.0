From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH] net-packet: tx timestamping on tpacket ring
Date: Mon, 15 Apr 2013 12:37:52 -0400
Message-ID: <CA+FuTSdgg9A8PRF4GaVSBTJ4db_i2mRQD6kWe3xXM86Y5op0Uw@mail.gmail.com>
References: <CA+FuTSezggEb7znDYMf8vWU7JmWLP59AVPkaTvNaAwJoNcqk9A@mail.gmail.com>
 <1365879412-9541-1-git-send-email-willemb@google.com> <516BACC2.7060400@onera.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Richard Cochran <richardcochran@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	daniel.borkmann@tik.ee.ethz.ch, xemul@parallels.com,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: Paul Chavent <Paul.Chavent@onera.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:61684 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab3DOQiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 12:38:24 -0400
Received: by mail-ie0-f176.google.com with SMTP id x14so1757326ief.35
        for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 09:38:23 -0700 (PDT)
In-Reply-To: <516BACC2.7060400@onera.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 15, 2013 at 3:31 AM, Paul Chavent <Paul.Chavent@onera.fr> wrote:
> Hi.
>
>
> On 04/13/2013 08:56 PM, Willem de Bruijn wrote:
>>
>> [...]
>>
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3311,7 +3311,7 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
>>                  * so keep the shared tx_flags and only
>>                  * store software time stamp
>>                  */
>> -               skb->tstamp = ktime_get_real();
>> +               orig_skb->tstamp = skb->tstamp = ktime_get_real();
>>         }
>
>
> You said that "the orig_skb is usually freed shortly after
> skb_tstamp_tx is called".
>
> So i suppose that if you had coded it, that's because this orig_skb is the
> one that is given to the skb destructor. So when you call
> __packet_set_timestamp, in tpacket_destruct_skb, you get this timestamp ? Am
> i right ?
>
>
> Why we couldn't call
> *skb_hwtstamps(orig_skb) = *skb_hwtstamps(skb) = *hwtstamps;
> in order to get the hardware timestamping too ?

Probably. That would also answer Daniel's question to the same
functionality. I'm a bit less familiar with the hardware path, so will
read up before just submitting it.

> Thank for your help.
>
> Paul.
