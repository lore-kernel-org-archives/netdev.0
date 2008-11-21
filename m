From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] fs: pipe/sockets/anon dentries should not have a parent
Date: Fri, 21 Nov 2008 10:36:26 -0500
Message-ID: <20081121153626.GA9281@infradead.org>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <20081121083044.GL16242@elte.hu> <49267694.1030506@cosmosbay.com> <20081121.010508.40225532.davem@davemloft.net> <4926AEDB.10007@cosmosbay.com> <4926D022.5060008@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mingo@elte.hu,
	cl@linux-foundation.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	kernel-testers@vger.kernel.org, efault@gmx.de,
	a.p.zijlstra@chello.nl, Linux Netdev List <netdev@vger.kernel.org>,
	viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4926D022.5060008@cosmosbay.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2008 at 04:13:38PM +0100, Eric Dumazet wrote:
> [PATCH] fs: pipe/sockets/anon dentries should not have a parent
>
> Linking pipe/sockets/anon dentries to one root 'parent' has no functional
> impact at all, but a scalability one.
>
> We can avoid touching a cache line at allocation stage (inside d_alloc(), no need
> to touch root->d_count), but also at freeing time (in d_kill, decrementing d_count)
> We avoid an expensive atomic_dec_and_lock() call on the root dentry.
>
> If we correct dnotify_parent() and inotify_d_instantiate() to take into account
> a NULL d_parent, we can call d_alloc() with a NULL parent instead of root dentry.

Sorry folks, but a NULL d_parent is a no-go from the VFS perspective,
but you can set d_parent to the dentry itself which is the magic used
for root of tree dentries.  They should also be marked
DCACHE_DISCONNECTED to make sure this is not unexpected.

And this kind of stuff really needs to go through -fsdevel.
