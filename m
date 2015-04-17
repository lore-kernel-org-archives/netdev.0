From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 14:04:38 -0400
Message-ID: <20150417180438.GE16743@htj.duckdns.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <201504180035.AIJ09349.SOFFHFtLOOQVMJ@I-love.SAKURA.ne.jp>
 <20150417162826.GB16743@htj.duckdns.org>
 <20150417.131712.1245246947203158168.davem@davemloft.net>
 <20150417173754.GC16743@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penguin-kernel@I-love.SAKURA.ne.jp, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150417173754.GC16743@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just a bit of addition.

On Fri, Apr 17, 2015 at 01:37:54PM -0400, Tejun Heo wrote:
> Upto patch 12, it's just the same mechanism transferring extended
> messages.  It doesn't add any smartness to netconsole per-se except
> that it can now emit messages with metadata headers.  What do you
> think about them?

So, as long as netconsole can send messages with metadata header,
moving the reliability part to userland is trivial.  All that's
necessary is a program which follows /dev/kmsg, keeps the unacked
sequences and implement the same retransmission mechanism.  It'd be
less reobust in certain failure scenarios and a bit more cumbersome to
set up but nothing major and if we do that there'd be no reason to
keep the userland part in the kernel tree.

If the retransmission and timer parts are bothering, moving those to
userland sounds like an acceptable compromise.

Thanks.

-- 
tejun
