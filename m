From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH v3 1/7] fs: Use a percpu_counter to track nr_dentry
Date: Tue, 24 Jul 2007 11:24:51 +1000
Message-ID: <200707241124.52675.nickpiggin@yahoo.com.au>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com> <49419680.8010409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Christoph Hellwig <hch@infradead.org>,
	David Miller <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org,
	"kernel-testers@vger.kernel.org >> Kernel Testers List"
	<kernel-testers@vger.kernel.org>, Mike Galbraith <efault@gmx.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <49419680.8010409@cosmosbay.com>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 12 December 2008 09:38, Eric Dumazet wrote:
> Adding a percpu_counter nr_dentry avoids cache line ping pongs
> between cpus to maintain this metric, and dcache_lock is
> no more needed to protect dentry_stat.nr_dentry
>
> We centralize nr_dentry updates at the right place :
> - increments in d_alloc()
> - decrements in d_free()
>
> d_alloc() can avoid taking dcache_lock if parent is NULL
>
> ("socketallocbench -n8" result : 27.5s to 25s)

Seems like a good idea.


> @@ -696,7 +712,7 @@ static void shrink_dcache_for_umount_subtree(struct
> dentry *dentry) * otherwise we ascend to the parent and move to the
>  			 * next sibling if there is one */
>  			if (!parent)
> -				goto out;
> +				return;
>
>  			dentry = parent;
>

Andrew doesn't like return from middle of function.
