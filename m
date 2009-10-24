From: David Miller <davem@davemloft.net>
Subject: Re: Irq architecture for multi-core network driver.
Date: Sat, 24 Oct 2009 06:26:28 -0700 (PDT)
Message-ID: <20091024.062628.263337033.davem@davemloft.net>
References: <m13a5apmm0.fsf@fess.ebiederm.org>
	<4807377b0910231028g60b479cfycdbf3f4e25384c58@mail.gmail.com>
	<m17huln1ab.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@gmail.com, ddaney@caviumnetworks.com,
	cfriesen@nortel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753436AbZJXN0H@vger.kernel.org>
In-Reply-To: <m17huln1ab.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 23 Oct 2009 16:22:36 -0700

> irqbalance is actually more likely to move irqs than the hardware.
> I have heard promises it won't move network irqs but I have seen
> the opposite behavior.

It knows what network devices are named, and looks for those keys
in /proc/interrupts.  Anything names 'ethN' will not be moved and
if you name them on a per-queue basis properly (ie. 'ethN-RX1' etc.)
it will flat distribute those interrupts amongst the cpus in the
machine.

So if you're doing "silly stuff" and naming your devices by some other
convention, you would end up defeating the detations built into
irqbalanced.

Actually, let's not even guess, go check out the sources of the
irqbalanced running on your system and make sure it has the network
device logic in it. :-)
