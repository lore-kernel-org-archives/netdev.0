From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] af_pppox: create module infrastructure for protocol
	modules
Date: 30 Apr 2003 11:11:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1051726260.13512.59.camel@localhost.localdomain>
References: <20030428.222728.48508327.davem@redhat.com>
	 <20030429065419.GN25361@conectiva.com.br>
	 <5.1.0.14.2.20030429123317.10d71178@unixmail.qualcomm.com>
	 <20030429.192931.104061911.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030429.192931.104061911.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-04-29 at 19:29, David S. Miller wrote:
>    From: Max Krasnyansky <maxk@qualcomm.com>
>    Date: Tue, 29 Apr 2003 13:05:08 -0700
> 
>    - Why do we have to bump module refcount for 'struct sock' with
>      _default_ callbacks ?
> 
> Nothing says that just because a sock uses default callbacks, it can't
> be referenced in other ways by the implementation module, for example
> it can sit in the protocol hash tables and that by itself requires
> a module reference.
That's a good point. However this is protocol's local business.
Netcore does not use those hashes directly. Netcore only uses things
like sk->state, sk->lock, etc and callbacks. So the callback is the only
reference, from netcore's point of view, into the protocol module.
Most protocols that I've looked at unlink sk from its hashes in
proto_sock_release(struct socket *sock) so it's enough to make sure that
struct socket is accounted for.  
And like I said before if protocol wants for some reason to be around
until sk is destroyed it will simply do sk_set_owner() right after
alloc_sk().

Max
