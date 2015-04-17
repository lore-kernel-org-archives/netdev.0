From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 13:37:54 -0400
Message-ID: <20150417173754.GC16743@htj.duckdns.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <201504180035.AIJ09349.SOFFHFtLOOQVMJ@I-love.SAKURA.ne.jp>
 <20150417162826.GB16743@htj.duckdns.org>
 <20150417.131712.1245246947203158168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: penguin-kernel@I-love.SAKURA.ne.jp, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150417.131712.1245246947203158168.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, David.

On Fri, Apr 17, 2015 at 01:17:12PM -0400, David Miller wrote:
> If userland cannot run properly, it is almost certain that neither will
> your complex reliability layer logic.

* The bulk of patches are to pipe extended log messages to console
  drivers and let netconsole relay them to the receiver (and quite a
  bit of refactoring in the process), which, regardless of the
  reliability logic, is beneficial as we're currently losing
  structured logging (dictionary) and other metadata over consoles and
  regardless of where the reliability logic is implemented, it's a lot
  easier to have messages IDs.

* The only thing necessary for reliable transmission are timer and
  netpoll.  There sure are cases where they go down too but there's a
  pretty big gap between those two going down and userland getting
  hosed, but where to put the retransmission and reliability logic
  definitely is debatable.

* That said, the "reliability" part of the patch series are just two
  patches - 13 and 14, both of which are actually pretty simple.

> I tend to agree with Tetsuo, that in-kernel netconsole should remain
> as simple as possible and once it starts to have any smarts and less
> trivial logic the job belongs in userspace.

Upto patch 12, it's just the same mechanism transferring extended
messages.  It doesn't add any smartness to netconsole per-se except
that it can now emit messages with metadata headers.  What do you
think about them?

Thanks.

-- 
tejun
