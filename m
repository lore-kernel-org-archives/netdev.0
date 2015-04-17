From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 13:17:12 -0400 (EDT)
Message-ID: <20150417.131712.1245246947203158168.davem@davemloft.net>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
	<201504180035.AIJ09349.SOFFHFtLOOQVMJ@I-love.SAKURA.ne.jp>
	<20150417162826.GB16743@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: tj@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150417162826.GB16743@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tejun Heo <tj@kernel.org>
Date: Fri, 17 Apr 2015 12:28:26 -0400

> On Sat, Apr 18, 2015 at 12:35:06AM +0900, Tetsuo Handa wrote:
>> If the sender side can wait for retransmission, why can't we use
>> userspace programs (e.g. rsyslogd)?
> 
> Because the system may be oopsing, ooming or threshing excessively
> rendering the userland inoperable and that's exactly when we want
> those log messages to be transmitted out of the system.

If userland cannot run properly, it is almost certain that neither will
your complex reliability layer logic.

I tend to agree with Tetsuo, that in-kernel netconsole should remain
as simple as possible and once it starts to have any smarts and less
trivial logic the job belongs in userspace.
