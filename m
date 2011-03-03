From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC v1: sysctl: add sysctl header cookie, share tables between nets
Date: Thu, 03 Mar 2011 01:33:43 -0800
Message-ID: <m1zkpc1rbc.fsf@fess.ebiederm.org>
References: <1298659961-23863-1-git-send-email-lucian.grijincu@gmail.com>
	<20110302.170644.58413369.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lucian.grijincu@gmail.com, adobriyan@gmail.com, tavi@cs.pub.ro,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110302.170644.58413369.davem@davemloft.net> (David Miller's
	message of "Wed, 02 Mar 2011 17:06:44 -0800 (PST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
> Date: Fri, 25 Feb 2011 20:52:32 +0200
>
>> This is a new approach to the "share sysctl tables" RFC series I
>> posted earlier this month.
>
> I do not disagree conceptually with these changes from a networking
> perspective, but I am not a sysctl layer expert so I don't know if the
> generic sysctl bits are a good idea or not.

I may be missing something in these patches. I haven't had time to look
at this most recent batch carefully.  But from a 10,000 foot perspective I
have a problem with them.  With a handful of network devices the size of
the data structures is negligible.

Where problems show up is when you have a lot of sysctl entries for
devices and at that point we have much larger problems using the
sysctl data structures.  Today add/remove are big O(previous entries)
and I think even readdir suffers from non-scalable data structures.

There are other related issues that the sysctl data structures are not
optimized for use in /proc, and that sysctl uses so usable but on off
locking like mechanisms.

Changing things to make the sysctl users more dependent on the current
implement details of the sysctl data structures seems the exact
opposite of the direction we need to go to make the sysctl data structures
scale.

So until I can see a reason why we should save a few bytes at the cost
of greater future maintenance costs I'm not in favor of this patch set.

Eric
