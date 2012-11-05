From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] pkt_sched: enable QFQ to support TSO/GSO
Date: Mon, 05 Nov 2012 11:46:19 -0500 (EST)
Message-ID: <20121105.114619.159498586351738155.davem@davemloft.net>
References: <20121030060056.GA3373@paolo-ThinkPad-W520>
	<20121030072415.17199f9a@nehalam.linuxnetplumber.net>
	<CAM_iQpUbru0EiO8yJYO2Uke_Y5v7047PEijkBHHpBn5DUbke5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, paolo.valente@unimore.it, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUbru0EiO8yJYO2Uke_Y5v7047PEijkBHHpBn5DUbke5Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 5 Nov 2012 16:41:49 +0800

> On Tue, Oct 30, 2012 at 10:24 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
>> On Tue, 30 Oct 2012 07:00:56 +0100
>> Paolo Valente <paolo.valente@unimore.it> wrote:
>>
>>> Hi,
>>> if the max packet size for some class (configured through tc) is
>>> violated by the actual size of the packets of that class, then QFQ
>>> would not schedule classes correctly, and the data structures
>>> implementing the bucket lists may get corrupted. This problem occurs
>>> with TSO/GSO even if the max packet size is set to the MTU, and is,
>>> e.g., the cause of the failure reported in [1]. Two patches have been
>>> proposed to solve this problem in [2], one of them is a preliminary
>>> version of this patch.
>>>
>>> This patch addresses the above issues by: 1) setting QFQ parameters to
>>> proper values for supporting TSO/GSO (in particular, setting the
>>> maximum possible packet size to 64KB), 2) automatically increasing the
>>> max packet size for a class, lmax, when a packet with a larger size
>>> than the current value of lmax arrives.
>>>
>>> The drawback of the first point is that the maximum weight for a class
>>> is now limited to 4096, which is equal to 1/16 of the maximum weight
>>> sum.
>>>
>>> Finally, this patch also forcibly caps the timestamps of a class if
>>> they are too high to be stored in the bucket list. This capping, taken
>>> from QFQ+ [3], handles the unfrequent case described in the comment to
>>> the function slot_insert.
>>>
>>> [1] http://marc.info/?l=linux-netdev&m=134968777902077&w=2
>>> [2] http://marc.info/?l=linux-netdev&m=135096573507936&w=2
>>> [3] http://marc.info/?l=linux-netdev&m=134902691421670&w=2
>>>
>>> Signed-off-by: Paolo Valente <paolo.valente@unimore.it>
>>> Tested-by: Cong Wang <amwang@redhat.com>
>>
>> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> David, could you take this patch? Stephen acked it.

It's "RFC" so it needs to be explicitly reposted.
