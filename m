From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] rxrpc: fix uninitialized variable use
Date: Tue, 21 Jun 2016 09:48:52 +0100
Message-ID: <3356.1466498932@warthog.procyon.org.uk>
References: <20160617095555.1696781-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160617095555.1696781-1-arnd@arndb.de>
Content-ID: <3355.1466498932.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> wrote:

> Hashing the peer key was introduced for AF_INET, but gcc
> warns about the rxrpc_peer_hash_key function returning uninitialized
> data for any other value of srx->transport.family:
> 
> net/rxrpc/peer_object.c: In function 'rxrpc_peer_hash_key':
> net/rxrpc/peer_object.c:57:15: error: 'p' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> Assuming that nothing else can be set here, this changes the
> function to just return zero in case of an unknown address
> family.

I'm actually more tempted to put a BUG() in there because if any new family
support (say AF_INET6) is added, I want to make sure I catch all the places.

David
