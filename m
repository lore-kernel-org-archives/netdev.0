From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 3/6] block/genhd.c: apply
 pm_runtime_set_memalloc_noio on block devices
Date: Tue, 6 Nov 2012 15:24:27 -0800
Message-ID: <20121106152427.dfde4c52.akpm@linux-foundation.org>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<1351931714-11689-4-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>,
 Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki"
 <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller"
 <davem@davemloft.net>, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-pm@vger.kernel.org, linux-mm@kvack.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1351931714-11689-4-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sat,  3 Nov 2012 16:35:11 +0800
Ming Lei <ming.lei@canonical.com> wrote:

> This patch applyes the introduced pm_runtime_set_memalloc_noio on
> block device so that PM core will teach mm to not allocate memory with
> GFP_IOFS when calling the runtime_resume and runtime_suspend callback
> for block devices and its ancestors.
> 
> ...
>
> @@ -532,6 +533,13 @@ static void register_disk(struct gendisk *disk)
>  			return;
>  		}
>  	}
> +
> +	/* avoid probable deadlock caused by allocating memory with

Again, please fix the comment style.  Take a look at the rest of this file!

> +	 * GFP_KERNEL in runtime_resume callback of its all ancestor
> +	 * deivces

typo

> +	 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
