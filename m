From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v5 1/6] mm: teach mm by current context info to not do I/O
 during memory allocation
Date: Sun, 11 Nov 2012 20:41:20 +0800
Message-ID: <CACVXFVPMd11NPXLE=Ttj75ScMGHLvAYcYMjAyCmRvU3KZauqzg@mail.gmail.com>
References: <1352637278-19968-1-git-send-email-ming.lei@canonical.com>
	<1352637278-19968-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>,
	Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org,
	Ming Lei <ming.lei@canonical.com>, Jiri Kosina <jiri.kosina@suse.com>,
	Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
To: linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1352637278-19968-2-git-send-email-ming.lei@canonical.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2012 at 8:34 PM, Ming Lei <ming.lei@canonical.com> wrote:
> +/* GFP_NOIO isn't allowed if PF_MEMALLOC_NOIO is set in current->flags */
> +static inline gfp_t memalloc_noio_flags(gfp_t flags)
> +{
> +       if (unlikely(current->flags & PF_MEMALLOC_NOIO))
> +               flags &= ~GFP_NOIO;
> +       return flags;

Sorry, the above is wrong, and GFP_IO should be cleared, and I will
resend this one.


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
