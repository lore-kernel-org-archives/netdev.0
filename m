From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH][NET] generalise per socket slab cache use
Date: Mon, 13 Sep 2004 18:51:08 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409131851.10705.acme@conectiva.com.br>
References: <200409110023.34342.acme@conectiva.com.br> <Pine.LNX.4.58.0409131410540.19499@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S.Miller" <davem@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0409131410540.19499@localhost.localdomain>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Seg 13 Set 2004 18:17, Sridhar Samudrala escreveu:
> Arnaldo,
>
> looks good, but i have a few comments. It is great that SCTP now has its
> own slabcaches.
>
> > +struct ipv6_sk_offset raw_sock_offset = {
> > +     .offset = offsetof(struct udp6_sock, inet6),
> > +};
>
> I think there is a typo here. udp6_sock should be raw6_sock

Good spotting! I'll fix this one

> > -                printk(KERN_CRIT "%s: Can't create protocol sock SLAB "
> > -                    "caches!\n", __FUNCTION__);
>
> You have removed the above critical messages. Is this by intent or a
> mistake.

Humm, I'll put it on the sk_alloc_slab callers

>
> I am not clear on why we need this new structure ipv6_sk_offset.
>
> > +struct ipv6_sk_offset {
> > +     int     offset;
> > +};
> > +
>
> Instead of adding the new field void *af_specific to struct proto, is it
> not sufficient to add
>         int     pinet6_offset;
>
> and assign it as follows for each v6 sock type
>         .pinet6_offset = offsetof(struct struct tcp6_sock, inet6)
>
> In inet6_sk_generic(), you can directly use sk->sk_prot->pinet6_offset.

I thought about it, but idea was to not introduce any family specific stuff in
struct proto, I don't plan to have LLC over IPv6, for instance :)

> Thanks
> Sridhar
