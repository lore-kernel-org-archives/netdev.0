From: Patrick McHardy <kaber@trash.net>
Subject: Re: kfree_skb: unnecessary check ?
Date: Wed, 19 Jun 2002 23:32:19 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D10F863.4070204@trash.net>
References: <200206192026.AAA17502@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

kuznet@ms2.inr.ac.ru wrote:

>Hello!
>
>>Is atomic_dec_and_test really necessary ? atomic_dec_and_test only 
>>returns true if its argument has hit zero, so it was 1 before.
>>If atomic_dec is only a bit cheaper than atomic_dec_and_test (which i 
>>guess it is), wouldn't it make more sense to use something like this:
>>
>
>Does the prefix "atomic" not scare you? :-)
>
>
>>static inline void kfree_skb(struct sk_buff *skb)
>>{
>>    if (atomic_read(&skb->users) == 1)
>>        __kfree(skb);
>>    else
>>        atomic_dec(&skb->users);
>>}
>>
>
>      else if (atomic_dec_and_test(&skb->users))
>	   __kfree_skb(skb);
>
>If you still do not understand think why it does not look like:
>
>static inline void kfree_skb(struct sk_buff *skb)
>{
>    int users = skb->users;
>    if (users == 1)
>        __kfree(skb);
>    else
>        skb->users = users - 1;
>}
>
>Alexey
>

Hehe got it :)
Thanks
Patrick
