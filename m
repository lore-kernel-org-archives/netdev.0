From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 05/11] mm: swap: Implement generic handler for
 swap_activate
Date: Tue, 1 May 2012 15:57:47 -0700
Message-ID: <20120501155747.368a1d36.akpm@linux-foundation.org>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
	<1334578675-23445-6-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>,
 Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 David Miller <davem@davemloft.net>, Trond Myklebust
 <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig
 <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie
 <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1334578675-23445-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Apr 2012 13:17:49 +0100
Mel Gorman <mgorman@suse.de> wrote:

> The version of swap_activate introduced is sufficient for swap-over-NFS
> but would not provide enough information to implement a generic handler.
> This patch shuffles things slightly to ensure the same information is
> available for aops->swap_activate() as is available to the core.
> 
> No functionality change.
> 
> ...
>
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -587,6 +587,8 @@ typedef struct {
>  typedef int (*read_actor_t)(read_descriptor_t *, struct page *,
>  		unsigned long, unsigned long);
>  
> +struct swap_info_struct;

Please put forward declarations at top-of-file.  To prevent accidental
duplication later on.

>  struct address_space_operations {
>  	int (*writepage)(struct page *page, struct writeback_control *wbc);
>  	int (*readpage)(struct file *, struct page *);
>
> ...
>
> --- a/mm/page_io.c
> +++ b/mm/page_io.c

Have you tested all this code with CONFIG_SWAP=n?

Have you sought to minimise additional new code when CONFIG_SWAP=n?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
