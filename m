From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH 2/5] net: Call sk_mark_napi_id() in the ACK
 receive path
Date: Thu, 16 Mar 2017 15:36:21 -0700
Message-ID: <CAKgT0UeEstUeZ8J-Q9EmUvHZS1id=xND=tME9XhKjOOg+t66UQ@mail.gmail.com>
References: <20170316183142.15806.38824.stgit@localhost.localdomain>
 <20170316183244.15806.77453.stgit@localhost.localdomain> <1489701893.28631.248.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489701893.28631.248.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 16, 2017 at 3:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-03-16 at 11:32 -0700, Alexander Duyck wrote:
>> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
>>
>> Call sk_mark_napi_id() in the ACK receive path of a TCP_NEW_SYN_RECV
>> socket, so that sk->napi_id is set even if the socket hasn't yet received
>> any data.  With this change we should be able to start busy polling
>> slightly earlier.
>>
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>  net/ipv4/tcp_ipv4.c |    1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
>> index 08d870e45658..b86002a296f1 100644
>> --- a/net/ipv4/tcp_ipv4.c
>> +++ b/net/ipv4/tcp_ipv4.c
>> @@ -1687,6 +1687,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
>>                       tcp_v4_send_reset(nsk, skb);
>>                       goto discard_and_relse;
>>               } else {
>> +                     sk_mark_napi_id(nsk, skb);
>>                       sock_put(sk);
>>                       return 0;
>>               }
>>
>
> Seems good, but what about IPv6 ?

Sorry, I spaced out and overlooked that this would also be an issue for IPv6.

> Frankly this calls for the sk_mark_napi_id() being done in
> tcp_child_process() instead of its four callers.

We can look into that for the next version.
