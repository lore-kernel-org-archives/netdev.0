From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Date: Fri, 9 Sep 2011 09:00:08 -0400
Message-ID: <20110909130007.GA11810@infradead.org>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-4-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux-MM <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Linux-Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux-NFS <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
To: Mel Gorman <mgorman-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1315566054-17209-4-git-send-email-mgorman-l3A5Bk7waGM@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 09, 2011 at 12:00:47PM +0100, Mel Gorman wrote:
> Currently swapfiles are managed entirely by the core VM by using
> ->bmap to allocate space and write to the blocks directly. This
> patch adds address_space_operations methods that allow a filesystem
> to optionally control the swapfile.
> 
>   int swap_activate(struct file *);
>   int swap_deactivate(struct file *);
>   int swap_writepage(struct file *, struct page *, struct writeback_control *);
>   int swap_readpage(struct file *, struct page *);

Just as the last two dozen times this came up:

NAK

The right fix is to add a filesystem method to support direct-I/O on
arbitrary kernel pages, instead of letting the wap abstraction leak into
the filesystem.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
