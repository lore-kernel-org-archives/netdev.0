From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] allow setting mtu and txqlen via RTM_SETLINK and provide txqlen via RTM_GETLINK
Date: Tue, 24 Aug 2004 20:16:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BzYMJ-000208-00@gondolin.me.apana.org.au>
References: <20040824094952.GF21073@postel.suug.ch>
Cc: herbert@gondor.apana.org.au, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20040824094952.GF21073@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> * Herbert Xu <E1BzR1C-0000c4-00@gondolin.me.apana.org.au> 2004-08-24 12:26
>> Thomas Graf <tgraf@suug.ch> wrote:
>> >
>> > +       RTA_PUT(skb, IFLA_TXQLEN, sizeof(unsigned long), &dev->tx_queue_len);
>> 
>> Please use a fixed width type like u32.
> 
> I used the same type as it is stored in struct net_device to avoid data
> loss on certain architectures. Due to the fact that the size of the
> attribute is provided to the userspace receiver, no guessing is involved.
> Using u32 would mean to do an unnecessary cast.

Please think about the meaning of the value.  Is anyone going to have a queue
bigger than 2^32?

And if the answer is yes, then please use u64.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
