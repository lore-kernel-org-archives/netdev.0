From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 13:45:22 -0400
Message-ID: <20150417174522.GD16743@htj.duckdns.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <201504180035.AIJ09349.SOFFHFtLOOQVMJ@I-love.SAKURA.ne.jp>
 <20150417162826.GB16743@htj.duckdns.org>
 <20150417.131712.1245246947203158168.davem@davemloft.net>
 <20150417173754.GC16743@htj.duckdns.org>
 <201504180243.IDB78159.tFVOOFQFSOHLMJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201504180243.IDB78159.tFVOOFQFSOHLMJ@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 18, 2015 at 02:43:30AM +0900, Tetsuo Handa wrote:
> > Upto patch 12, it's just the same mechanism transferring extended
> > messages.  It doesn't add any smartness to netconsole per-se except
> > that it can now emit messages with metadata headers.  What do you
> > think about them?
> 
> So, this patchset aims for obtaining kernel messages under problematic
> condition. You have to hold messages until ack is delivered. This means
> that printk buffer can become full before burst messages (e.g. SysRq-t)
> are acked due to packet loss in the network.
> 
> printk() cannot wait for ack. Trying to wait for ack would break something.
> How can you transmit subsequent kernel messages which failed to enqueue
> due to waiting for ack for previous kernel messages?

Well, if log buffer overflows and the messages aren't at the logging
target yet, they're lost.  It's the same as doing dmesg on localhost,
isn't it?  This doesn't have much to do with where the reliability
logic is implemented and is exactly the same with local logging too.

Thanks.

-- 
tejun
