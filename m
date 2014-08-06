From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 6 Aug 2014 09:08:16 -0400
Message-ID: <CA+FuTSdqxXOod_V6+cfYdLgFZ1mabi1O34UT92XEpqGiFtfz1g@mail.gmail.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
 <1407204710-21778-6-git-send-email-willemb@google.com> <1407308141.14097.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:48900 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbaHFNIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 09:08:46 -0400
Received: by mail-qa0-f41.google.com with SMTP id j7so2413809qaq.0
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 06:08:46 -0700 (PDT)
In-Reply-To: <1407308141.14097.9.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2014 at 2:55 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-08-04 at 22:11 -0400, Willem de Bruijn wrote:
>> TCP timestamping extends SO_TIMESTAMPING to bytestreams.
>
>>
>> +void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
>> +{
>> +     struct skb_shared_info *shinfo = skb_shinfo(skb);
>> +
>> +     sock_tx_timestamp(sk, &shinfo->tx_flags);
>
> Arg, this breaks SKBTX_SHARED_FRAG support.
>
> And sock_tx_timestamp() is quite expensive for TCP where only
> SKBTX_ACK_TSTAMP could possibly be supported ?

The other options can also be set. But it is expensive. It can
actually be wrapped into a branch if (sk->sk_tsflags), to avoid
calling the function in the common case.

>
> static void tcp_tx_timestamp(const struct sock *sk, struct sk_buff *skb)
>
> I'll send a cumulative patch.

Thanks for spotting and fixing the critical shared frags issue. I
can send a patch for this, the two static functions identified by
sparse and the sequence number arithmetic in tcp_gso_tstamp.
>
>
