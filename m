From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] kevent_user: use struct kevent_mring for the page ring
Date: Tue, 22 Aug 2006 16:20:43 +0400
Message-ID: <20060822122043.GB4815@2ka.mipt.ru>
References: <12345678912345.GA1898@2ka.mipt.ru> <11561555871530@2ka.mipt.ru> <20060822115504.GB10839@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34959 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932204AbWHVMVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 08:21:31 -0400
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20060822115504.GB10839@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2006 at 12:55:04PM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> Currently struct kevent_user.print is an array of unsigned long, but it's used
> as an array of pointers to struct kevent_mring everyewhere in the code.
> 
> Switch it to use the real type and cast the return value from __get_free_page /
> argument to free_page.
> 
> 
>  include/linux/kevent.h      |    2 +-
>  kernel/kevent/kevent_user.c |   31 +++++++++++--------------------
>   2 files changed, 12 insertions(+), 21 deletions(-)
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

I will apply this patch with small minor nit below.

>  	if (idx >= u->pages_in_use) {
> -		u->pring[idx] = __get_free_page(GFP_KERNEL);
> +		u->pring[idx] = (void *)__get_free_page(GFP_KERNEL);

Better cast it directly to (struct kevent_mring *).


If there will not be any objectsion about syscall-based initialization,
I will release new patchset tomorrow with your changes.

Thank you, Christoph.

-- 
	Evgeniy Polyakov
