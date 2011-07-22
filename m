From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Linux 3.0 release
Date: Fri, 22 Jul 2011 13:32:20 -0700
Message-ID: <20110722133220.0baf2199@nehalam.ftrdhcpuser.net>
References: <CA+55aFxakA2U+oMJ1T7awTYa+p6xp9N0aCbfrUqgkF7BJ8gnQw@mail.gmail.com>
	<4E29CB5B.4040408@unsolicited.net>
	<CA+55aFy1FnVGH4C_0T8fXwZPUdz5-SCczMwy1K8kydLwTx89RQ@mail.gmail.com>
	<4E29D326.7070403@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David <david@unsolicited.net>, Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E29D326.7070403@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This a regression which probably began with

commit e22bee782b3b00bd4534ae9b1c5fb2e8e6573c5c
Author: Tejun Heo <tj@kernel.org>
Date:   Tue Jun 29 10:07:14 2010 +0200

    workqueue: implement concurrency managed dynamic worker pool

Before that it was perfectly legal for link watch code to
call schedule_delayed_work from IRQ. This should be allowable;
the code to manage the worker pool should handle it.

Network devices call netif_carrier_on/off from IRQ all the
time. The problem is that the new pool code breaks this
if link watch tries to schedule work before there enough worker
threads.

The workqueue code should have a fallback and not try and
do anything if being called from IRQ.
