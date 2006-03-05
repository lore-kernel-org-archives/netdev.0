From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 8/8] [I/OAT] TCP recv offload to I/OAT
Date: Sun, 05 Mar 2006 02:27:35 -0800 (PST)
Message-ID: <20060305.022735.87818042.davem@davemloft.net>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	<20060303214236.11908.98881.stgit@gitlost.site>
	<20060305004534.1d94b3cf.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christopher.leech@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752241AbWCEK12@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <20060305004534.1d94b3cf.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Sun, 5 Mar 2006 00:45:34 -0800

> The __get_cpu_var() here will run smp_processor_id() from preemptible
> context.  You'll get a big warning if the correct debug options are set.
> 
> The reason for this is that preemption could cause this code to hop between
> CPUs.
> 
> Please always test code with all debug options enabled and with full kernel
> preemption.

To be fair that warning doesn't trigger on some platforms, such as
sparc64 where the __get_cpu_var() implementation simply takes the
value from a fixed cpu register and doesn't do the debugging check.

Sparc64 should add the check when debugging options are enabled, for
sure, but the point is that it may not entirely be the tester's fault.
:-)
