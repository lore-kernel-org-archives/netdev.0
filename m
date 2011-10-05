From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: linux-next: build failure after merge of the tip tree
Date: Wed, 05 Oct 2011 10:46:13 +0200
Message-ID: <1317804373.6766.0.camel@twins>
References: <20111005172528.0d0a8afc65acef7ace22a24e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20111005172528.0d0a8afc65acef7ace22a24e@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-10-05 at 17:25 +1100, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the tip tree, today's linux-next build (x86_64 allmodconfig)
> failed like this:
> 
> net/rds/ib_rdma.c: In function 'rds_ib_reuse_fmr':
> net/rds/ib_rdma.c:272:2: error: implicit declaration of function 'llist_del_first' [-Werror=implicit-function-declaration]
> net/rds/ib_rdma.c:272:6: warning: assignment makes pointer from integer without a cast [enabled by default]
> net/rds/ib_rdma.c: In function 'rds_ib_flush_mr_pool':
> net/rds/ib_rdma.c:671:4: error: implicit declaration of function 'llist_add_batch' [-Werror=implicit-function-declaration]
> cc1: some warnings being treated as errors
> 
> Caused by commit 1230db8e1543 ("llist: Make some llist functions inline")
> interacting with commit 1bc144b62524 ("net, rds, Replace xlist in
> net/rds/xlist.h with llist") from the net tree.  The former commit
> removes the declarations of llist_del_first() and llist_add_batch() with
> no explanation (and probably by accident since the definitions still
> exist).

Ugh yes, my bad. Ingo objected to inlining all those functions and I
then screwed up. There are no users of those two functions in my tree.
