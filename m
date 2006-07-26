From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 11:04:31 +0100
Message-ID: <20060726100431.GA7518@infradead.org>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:34195 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751173AbWGZKEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 06:04:32 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <11539054952574@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 01:18:15PM +0400, Evgeniy Polyakov wrote:
> 
> This patch includes asynchronous propagation of file's data into VFS
> cache and aio_sendfile() implementation.
> Network aio_sendfile() works lazily - it asynchronously populates pages
> into the VFS cache (which can be used for various tricks with adaptive
> readahead) and then uses usual ->sendfile() callback.

And please don't base this on sendfile.  Please make the splice infrastructure
aynschronous without duplicating all the code but rather make the existing
code aynch and the existing synchronous call wait on them to finish, similar
to how we handle async/sync direct I/O.  And to be honest, I don't think
adding all this code is acceptable if it can't replace the existing aio
code while keeping the interface.  So while you interface looks pretty
sane the implementation needs a lot of work still :)

