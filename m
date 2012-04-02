From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: check the length of the data before dereferencing it
Date: Mon, 2 Apr 2012 14:27:27 +0800
Message-ID: <CABa6K_GUMGC-cWPJyG_EcX_J3+w3cq4eZhuYqZYFgbcHHaXCNQ@mail.gmail.com>
References: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
 <1333336773.2325.6531.camel@edumazet-glaptop> <20120401.232942.1829187970291547571.davem@davemloft.net>
 <CABa6K_HfWckb=sv7oQatv2ZJm3EKJE0mutQQ-OiddXiR6E7eHg@mail.gmail.com>
 <1333338797.2325.6610.camel@edumazet-glaptop> <CABa6K_Hc7ZVVR6XvhEXKHNf_YNnrMNQLBTbxksvAJwAV9fer6w@mail.gmail.com>
 <1333342467.2325.6739.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1333342467.2325.6739.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 2, 2012 at 12:54 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2012-04-02 at 12:47 +0800, Changli Gao wrote:
>
>> Got it. Thanks. FYI, the tcp options are copied to the stack before
>> being parsed.
>>
>
> What do you mean ?
>
> code looks like :
>
> const struct tcphdr *th = tcp_hdr(skb);
> int length = (th->doff * 4) - sizeof(struct tcphdr);
>
> ptr = (const unsigned char *)(th + 1);
>
>
>
> Therefore ptr points somewhere in skb->head ...
>
>
>

Oh, sorry. I forgot to add the condition when I wrote it down. I mean
the code in netfilter.

        unsigned char buff[(15 * 4) - sizeof(struct tcphdr)];
        const unsigned char *ptr;
        int length = (tcph->doff*4) - sizeof(struct tcphdr);

        if (!length)
                return;

        ptr = skb_header_pointer(skb, dataoff + sizeof(struct tcphdr),
                                 length, buff);
        BUG_ON(ptr == NULL);

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
