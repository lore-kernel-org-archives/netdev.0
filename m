From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] new module infrastructure for net_proto_family
Date: Sat, 19 Apr 2003 19:57:59 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030419225759.GB6251@conectiva.com.br>
References: <20030419161457.GA6164@conectiva.com.br> <20030419.151706.86912986.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030419.151706.86912986.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sat, Apr 19, 2003 at 03:17:06PM -0700, David S. Miller escreveu:
>    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
>    Date: Sat, 19 Apr 2003 13:14:57 -0300
> 
> Have a look at this:

<SNIP>
 
>    -	if (sock->ops) 
>    +	if (sock->ops) {
>     		sock->ops->release(sock);
>    +		module_put(net_families[sock->ops->family]->owner);
>    +	}
 
> Maybe you want to cache sock->ops->family before calling
> sock->ops->release, maybe nobody does it but it could be
> legal to NULL sock->ops during sock->ops->release()
 
> If anything this code should NULL'ify it because any reference to sock->ops
> after the release and module_put() is a BUG() that should be trapped.

Ok, agreed, new changeset in the making.

- Arnaldo
