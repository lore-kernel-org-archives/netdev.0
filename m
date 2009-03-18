From: Andi Kleen <andi@firstfloor.org>
Subject: Re: High contention on the sk_buff_head.lock
Date: Wed, 18 Mar 2009 21:54:37 +0100
Message-ID: <87prge1rhu.fsf@basil.nowhere.org>
References: <49C12E64.1000301@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: Vernon Mauery <vernux@us.ibm.com>
Return-path: <linux-rt-users-owner@vger.kernel.org>
In-Reply-To: <49C12E64.1000301@us.ibm.com> (Vernon Mauery's message of "Wed, 18 Mar 2009 10:24:52 -0700")
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vernon Mauery <vernux@us.ibm.com> writes:
>
> So while this issue really hits -rt kernels hard, it has a real effect on
> mainline kernels as well.  The contention of the spinlocks is amplified
> when they get turned into rt-mutexes, which causes a double context switch.

The new adaptive spin heuristics that have been discussed some time
ago didn't help? Unsurprisingly making locks a lot more expensive
has drawbacks as you discovered.

>    &list->lock#3:      24517307       24643791           0.71        1286.62      56516392.42       34834296       44904018           0.60        164.79    31314786.02
>     -------------
>    &list->lock#3       15596927    [<ffffffff812474da>] dev_queue_xmit+0x2ea/0x468

The real "fix" would be probably to use a multi queue capable NIC
and a NIC driver that sets up multiple queues for TX (normally they
only do for RX). Then cores or a set of cores (often the number
of cores is larger than the number of NIC queues) could avoid this
problem. Disadvantage: more memory use.

But then again I'm not sure it's  worth it if the problem only
happens in out of tree RT.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
