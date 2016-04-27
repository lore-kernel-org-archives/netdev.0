From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 2/2] tcp: remove a redundant check for SKBTX_ACK_TSTAMP
Date: Wed, 27 Apr 2016 15:25:51 -0400
Message-ID: <CACSApvZ-i+q3iR3LXk_VF1XgNefRTx41H9hOFtUBHKD+pj-eSg@mail.gmail.com>
References: <1461617473-11349-1-git-send-email-soheil.kdev@gmail.com>
 <1461617473-11349-2-git-send-email-soheil.kdev@gmail.com> <20160427181938.GA54673@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:34067 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbcD0T0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 15:26:32 -0400
Received: by mail-oi0-f44.google.com with SMTP id k142so60263436oib.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 12:26:32 -0700 (PDT)
In-Reply-To: <20160427181938.GA54673@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 2:19 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Mon, Apr 25, 2016 at 04:51:13PM -0400, Soheil Hassas Yeganeh wrote:
>> From: Soheil Hassas Yeganeh <soheil@google.com>
>>
>> txstamp_ack in tcp_skb_cb is set iff the SKBTX_ACK_TSTAMP
>> flag is set for an skb. Thus, it is not required to check
>> shinfo->tx_flags if the txstamp_ack bit is checked.
>>
>> Remove the check on shinfo->tx_flags & SKBTX_ACK_TSTAMP, since
>> it has already been checked using the txstamp_ack bit.
>>
>> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
>> ---
>>  net/ipv4/tcp_input.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 967520d..2f3fd92 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -3087,8 +3087,7 @@ static void tcp_ack_tstamp(struct sock *sk, struct sk_buff *skb,
>>               return;
>>
>>       shinfo = skb_shinfo(skb);
>> -     if ((shinfo->tx_flags & SKBTX_ACK_TSTAMP) &&
>> -         !before(shinfo->tskey, prior_snd_una) &&
>> +     if (!before(shinfo->tskey, prior_snd_una) &&
>>           before(shinfo->tskey, tcp_sk(sk)->snd_una))
>>               __skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
>>  }
>> --
>> 2.8.0.rc3.226.g39d4020
>>
> Acked-by: Martin KaFai Lau <kafai@fb.com>
>
> Can it be one step further and completely remove SKBTX_ACK_TSTAMP?
> like what Willem has also suggested here:
> http://www.spinics.net/lists/netdev/msg374231.html
>
> It seems no one else is using the SKBTX_ACK_TSTAMP except TCP.

Ah, good point. Will update the patch then. Thanks!
