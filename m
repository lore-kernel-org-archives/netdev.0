From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH][NET] generalise per socket slab cache use
Date: Mon, 13 Sep 2004 14:17:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409131410540.19499@localhost.localdomain>
References: <200409110023.34342.acme@conectiva.com.br>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S.Miller" <davem@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <200409110023.34342.acme@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arnaldo,

looks good, but i have a few comments. It is great that SCTP now has its own
slabcaches.

> +struct ipv6_sk_offset raw_sock_offset = {
> +     .offset = offsetof(struct udp6_sock, inet6),
> +};

I think there is a typo here. udp6_sock should be raw6_sock

> -                printk(KERN_CRIT "%s: Can't create protocol sock SLAB "
> -                    "caches!\n", __FUNCTION__);

You have removed the above critical messages. Is this by intent or a mistake.

I am not clear on why we need this new structure ipv6_sk_offset.
> +struct ipv6_sk_offset {
> +     int     offset;
> +};
> +

Instead of adding the new field void *af_specific to struct proto, is it not
sufficient to add
        int     pinet6_offset;

and assign it as follows for each v6 sock type
        .pinet6_offset = offsetof(struct struct tcp6_sock, inet6)

In inet6_sk_generic(), you can directly use sk->sk_prot->pinet6_offset.

Thanks
Sridhar
