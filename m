From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2 net-next 1/4] net: socket: add support for async
 operations
Date: Thu, 19 Mar 2015 16:20:24 +0000
Message-ID: <20150319162024.GO29656@ZenIV.linux.org.uk>
References: <20150316161508.16418.23674.stgit@tstruk-mobl1>
 <20150316161514.16418.67336.stgit@tstruk-mobl1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-aio@kvack.org,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ying.xue@windriver.com, bcrl@kvack.org,
	linux-fsdevel@vger.kernel.org, hch@lst.de,
	linux-crypto@vger.kernel.org
To: Tadeusz Struk <tadeusz.struk@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55276 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127AbbCSQUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:20:35 -0400
Content-Disposition: inline
In-Reply-To: <20150316161514.16418.67336.stgit@tstruk-mobl1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 09:15:14AM -0700, Tadeusz Struk wrote:
> Add support for async operations.

NAK.  For the same reason as the last time - 

> +static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
> +			     unsigned long nr_segs, loff_t loff);
> +static ssize_t sock_aio_write(struct kiocb *iocb, const struct iovec *iov,
> +			      unsigned long nr_segs, loff_t loff);
> +

is completely pointless.  Just have sock_read_iter() and sock_write_iter()
check if your new methods are present and use those if those are.

What's more, I'm not at all sure that you want to pass iocb that way -
kernel-side msghdr isn't tied to userland one anymore, so we might as well
stash a pointer to iocb into it.  Voila - no new methods needed at all.
