From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 14:26:54 -0400
Message-ID: <20150417182654.GG16743@htj.duckdns.org>
References: <20150417173754.GC16743@htj.duckdns.org>
 <201504180243.IDB78159.tFVOOFQFSOHLMJ@I-love.SAKURA.ne.jp>
 <20150417174522.GD16743@htj.duckdns.org>
 <201504180303.GAB26011.OLJFSMVFFOHtOQ@I-love.SAKURA.ne.jp>
 <20150417180732.GF16743@htj.duckdns.org>
 <201504180320.CFG26062.FtSJLOOQOFVFMH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201504180320.CFG26062.FtSJLOOQOFVFMH@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Apr 18, 2015 at 03:20:41AM +0900, Tetsuo Handa wrote:
> I didn't mean to introduce netconsole's own version of metadata.
> I meant we don't need to implement in-kernel retry logic.

Hmmm?  I'm not really following where this discussion is headed.  No,
we don't have to put it in the kernel.  We can punt the retry part to
userland as I wrote in another message at some cost to robustness.

> If we can assume that scheduler is working, adding a kernel thread that
> does
> 
>   while (1) {
>       read messages with metadata from /dev/kmsg
>       send them using UDP network
>   }
> 
> might be easier than modifying netconsole module.

But, I mean, if we are gonna do that in kernel, we better do it
properly where it belongs.  What's up with "easier than modifying
netconsole module"?  Why is netconsole special?  And how would the
above be any less complex than a single timer function?  What am I
missing?

Thanks.

-- 
tejun
