From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] rxrpc: Tx length parameter
Date: Thu, 08 Jun 2017 11:42:03 -0400 (EDT)
Message-ID: <20170608.114203.1335498499864627385.davem@davemloft.net>
References: <149686995195.21359.17550471913376009423.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149686995195.21359.17550471913376009423.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Wed, 07 Jun 2017 22:12:32 +0100

> Here's a set of patches that allows someone initiating a client call with
> AF_RXRPC to indicate upfront the total amount of data that will be
> transmitted.  This will allow AF_RXRPC to encrypt directly from source
> buffer to packet rather than having to copy into the buffer and only
> encrypt when it's full (the encrypted portion of the packet starts with a
> length and so we can't encrypt until we know what the length will be).
> 
> The three patches are:
> 
>  (1) Provide a means of finding out what control message types are actually
>      supported.  EINVAL is reported if an unsupported cmsg type is seen, so
>      we don't want to set the new cmsg unless we know it will be accepted.
> 
>  (2) Consolidate some stuff into a struct to reduce the parameter count on
>      the function that parses the cmsg buffer.
> 
>  (3) Introduce the RXRPC_TX_LENGTH cmsg.  This can be provided on the first
>      sendmsg() that contributes data to a client call request or a service
>      call reply.  If provided, the user must provide exactly that amount of
>      data or an error will be incurred.
> 
> Changes in version 2:
> 
>  (*) struct rxrpc_send_params::tx_total_len should be s64 not u64.  Thanks to
>      Julia Lawall for reporting this.
 ...
> Tagged thusly:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
> 	rxrpc-rewrite-20170607-v2

Pulled, thanks David.
