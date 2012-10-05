From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] ipv6: clean up tcp_v6_early_demux() icsk variable
Date: Fri, 5 Oct 2012 12:25:14 -0400
Message-ID: <CADVnQymQonUHxeKrjDS2642F0=e=4NerqVv-t8PFgUpgM8k1UQ@mail.gmail.com>
References: <1349443284-14640-1-git-send-email-ncardwell@google.com>
	<1349445365.21172.74.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:47276 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932658Ab2JEQZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 12:25:15 -0400
Received: by mail-ie0-f174.google.com with SMTP id k13so4270172iea.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 09:25:14 -0700 (PDT)
In-Reply-To: <1349445365.21172.74.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, thanks, Eric. This sounds good. We can scrap this one, and we'll
do a full merge/clean-up when net-next is open.

neal

On Fri, Oct 5, 2012 at 9:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-10-05 at 09:21 -0400, Neal Cardwell wrote:
>> Remove an icsk variable, which by convention should refer to an
>> inet_connection_sock rather than an inet_sock. In the process, make
>> the tcp_v6_early_demux() code and formatting a bit more like
>> tcp_v4_early_demux(), to ease comparisons and maintenance.
>>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> ---
>>  net/ipv6/tcp_ipv6.c |    4 ++--
>>  1 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>> index 49c8903..491c41b 100644
>> --- a/net/ipv6/tcp_ipv6.c
>> +++ b/net/ipv6/tcp_ipv6.c
>> @@ -1740,11 +1740,11 @@ static void tcp_v6_early_demux(struct sk_buff *skb)
>>               skb->destructor = sock_edemux;
>>               if (sk->sk_state != TCP_TIME_WAIT) {
>>                       struct dst_entry *dst = sk->sk_rx_dst;
>> -                     struct inet_sock *icsk = inet_sk(sk);
>> +
>>                       if (dst)
>>                               dst = dst_check(dst, inet6_sk(sk)->rx_dst_cookie);
>>                       if (dst &&
>> -                         icsk->rx_dst_ifindex == skb->skb_iif)
>> +                         inet_sk(sk)->rx_dst_ifindex == skb->skb_iif)
>>                               skb_dst_set_noref(skb, dst);
>>               }
>>       }
>
> Hi Neal
>
> I would wait net-next being opened, and do a full merge/cleanup
>
> For example ipv6 uses :
>
> if (!pskb_may_pull(skb, skb_transport_offset(skb) +
>                    sizeof(struct tcphdr)))
> th = tcp_hdr(skb);
>
> while ipv4 uses :
>
> if (!pskb_may_pull(skb, ip_hdrlen(skb) + sizeof(struct tcphdr)))
> th = (struct tcphdr *) ((char *)iph + ip_hdrlen(skb));
>
> It would be good to use the ipv6 variant (its less instructions and
> cleaner)
>
> Same for the "struct net *net = dev_net(skb->dev);" used in ipv4, while
> ipv6 doesnt need this extra net variable.
>
> Thanks
>
>
