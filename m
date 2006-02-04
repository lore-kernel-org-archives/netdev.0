From: Holger Eitzenberger <holger@my-eitzenberger.de>
Subject: Re: Linux 2.6.15.2
Date: Sat, 4 Feb 2006 12:52:17 +0100
Message-ID: <20060204115217.GA5302@kruemel.my-eitzenberger.de>
References: <20060131070642.GA25015@kroah.com> <20060130233427.5e7912ae.akpm@osdl.org> <20060203120925.GA4393@kruemel.my-eitzenberger.de> <20060203111414.7026f46f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@suse.de, linux-kernel@vger.kernel.org, stable@kernel.org,
	torvalds@osdl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932277AbWBDNbE@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060203111414.7026f46f.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 03, 2006 at 11:14:14AM -0800, Andrew Morton wrote:

> http://www.mail-archive.com/netdev@vger.kernel.org/msg06355.html

> > A look into /proc/sys/net/ipv4/tcp_mem showed that that the values in
> > there were way to high.  I hope that a reduction of these values will
> > help (not done yet).

> Sounds different.  Please test a more recent kernel and if the problem is
> still there, send a report to linux-kernel and cc netdev@vger.kernel.org. 
> Include the contents of /proc/meminfo and /proc/slabinfo.  Thanks.

I solved the issue.

Recent kernels have alloc_large_system_hash() exactly for that, and
tcp_init() uses it.  It has nr_all_pages and nr_kernel_pages to
determine the actual size of usable RAM, whereas 2.6.10 just uses
num_physpages.  That's the reason why the values in tcp_mem are way
too high on machines with 3-4 Gig RAM.

Thanks.  /holger


-- 
ICQ 2882018 ++ Jabber: octavian@amessage.de ++
