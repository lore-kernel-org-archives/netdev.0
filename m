From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Wed, 16 Aug 2006 10:44:31 +0100
Message-ID: <20060816094431.GA21118@infradead.org>
References: <20060816091029.GA6375@infradead.org> <20060816093159.GA31882@2ka.mipt.ru> <20060816093837.GA11096@infradead.org> <20060816.024008.74744877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, johnpol@2ka.mipt.ru, arnd@arndb.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:28899 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751070AbWHPJoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 05:44:37 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060816.024008.74744877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 02:40:08AM -0700, David Miller wrote:
> From: Christoph Hellwig <hch@infradead.org>
> Date: Wed, 16 Aug 2006 10:38:37 +0100
> 
> > We could, but I'd rather waste 4 bytes in struct net_device than
> > having such ugly warts in common code.
> 
> Why not instead have struct device store some default node value?
> The node decision will be sub-optimal on non-pci but it won't crash.

Right now we don't even have the node stored in the pci_dev structure but
only arch-specific accessor functions/macros.  We could change those to
take a struct device instead and make them return -1 for everything non-pci
as we already do in architectures that don't support those helpers.  -1
means 'any node' for all common allocators.
