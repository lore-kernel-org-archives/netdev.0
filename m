From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocationAPIs
Date: Mon, 17 May 2010 10:34:30 +0900 (JST)
Message-ID: <20100517103050.21B6.A69D9226@jp.fujitsu.com>
References: <1273756816.5605.3547.camel@twins> <201005132236.ADJ57893.FLFFMtOVJHOOSQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, peterz@infradead.org,
	xiaosuo@gmail.com, akpm@linux-foundation.org, hnguyen@de.ibm.com,
	raisch@de.ibm.com, rolandd@cisco.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, divy@chelsio.com,
	James.Bottomley@suse.de, tytso@mit.edu, adilger@sun.com,
	viro@zeniv.linux.org.uk, menage@google.com, lizf@cn.fujitsu.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org, containers@lists.linux-foundation.org,
	eric.dumazet@gmail.com
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <201005132236.ADJ57893.FLFFMtOVJHOOSQ@I-love.SAKURA.ne.jp>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Peter Zijlstra wrote:
> > NAK, I really utterly dislike that inatomic argument. The alloc side
> > doesn't function in atomic context either. Please keep the thing
> > symmetric in that regards.
> 
> Excuse me. kmalloc(GFP_KERNEL) may sleep (and therefore cannot be used in
> atomic context). However, kfree() for memory allocated with kmalloc(GFP_KERNEL)
> never sleep (and therefore can be used in atomic context).
> Why kmalloc() and kfree() are NOT kept symmetric?

In kmalloc case, we need to consider both kmalloc(GFP_KERNEL)/kfree() pair and
kmalloc(GFP_ATOMIC)/kfree() pair. latter is mainly used on atomic context.
To make kfree() atomic help to keep the implementation simple.

But kvmalloc don't have GFP_ATOMIC feautre. that's big difference.



