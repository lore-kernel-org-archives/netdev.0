From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/5] AF_RXRPC: Add blkcipher accessors for using kernel data directly [try #2]
Date: Fri, 16 Mar 2007 13:32:38 +0000
Message-ID: <20070316133238.GA2173@infradead.org>
References: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <20070316125016.3740.96837.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:35418 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508AbXCPNcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 09:32:41 -0400
Content-Disposition: inline
In-Reply-To: <20070316125016.3740.96837.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 16, 2007 at 12:50:16PM +0000, David Howells wrote:
> Add blkcipher accessors for using kernel data directly without the use of
> scatter lists.

I don't quite understand all these indirections.  What's the problem
with just having a helper that builds the scatterlist for you?

> Also add a CRYPTO_ALG_DMA algorithm capability flag to permit or deny the use
> of DMA and hardware accelerators.  A hardware accelerator may not be used to
> access any arbitrary piece of kernel memory lest it not be in a DMA'able
> region.  Only software algorithms may do that.

We allow dma access to arbitary pieces of _dynamically_ allocated kernel
memory, and I think using the crypto subsystem on the stack is not allowed
at all.


But the even bigger question is, how does this relate to rxrpc?

> +static inline
> +void crypto_blkcipher_decrypt_kernel_iv(struct blkcipher_desc *desc,

very odd line split, please put the function name on the same line
as the qualifiers, or everything including the void on a line of it's
own.  The first option seems to be the preffered style in this file.

