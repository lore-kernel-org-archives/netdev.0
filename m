From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] merge sctp_opt with sctp_sock
Date: Mon, 17 Jan 2005 23:12:13 -0200
Message-ID: <41EC626D.1010804@conectiva.com.br>
References: <41E8A17D.9040307@conectiva.com.br> <20050117133327.0386763f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050117133327.0386763f.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller escreveu:
> On Sat, 15 Jan 2005 02:52:13 -0200
> Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:
> 
> 
>>	Please take a look and if its acceptable pull from:
>>
>>bk://kernel.bkbits.net/acme/connection_sock-2.6
>>
>>	The tricky bit here is that SCTP, to keep the existing logic,
>>needs a way to copy only its private area from one sock to another, so
>>I introduced a generic inet_sk_copy_descendant, that knows about the
>>inet (v4/v6) layout (wrt inet_sock and inet6_pinfo), using this and
>>sk->sk_prot->slab_obj_size we can copy the inet_sock descendant
>>private area generically.
> 
> 
> This looks fine, although I wish the descendant copying thing
> could be done more cleanly somehow.

/me too, but this is the best scheme I've found for now, perhaps in
the future, after some more refactoring work is done/merged we can
find some better way of doing this (tcp_create_openreq_child also
does something like this, but does it in all the sock, perhaps
SCTP can do something similar).

In fact my ambition is after mucho refactoring have some common
infrastructure even for child creation.

OK, back to chainsawing net/{ax25,netrom,rose} into a state where we
can actually use a slab cache for each of them, which is needed to
get the connection_sock abstraction into place, most of the work is
done, now I'm reading some HAM radio howtos and preparing a testbed
using bpqether, etc. Oh, there is another legacy family to send to
you first: IPv6 ;)

> Pulled.

Thanks.

- Arnaldo
