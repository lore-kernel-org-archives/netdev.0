From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Fwd: IGMP and rwlock: Dead ocurred again on TILEPro
Date: Thu, 17 Feb 2011 13:42:37 +0800
Message-ID: <20110217054237.GB2653@cr0.nay.redhat.com>
References: <AANLkTimj+_8cBz0gcEyF1889xK2HdF4SQDSK8DiY-4Gs@mail.gmail.com>
 <20110217044917.GA2653@cr0.nay.redhat.com>
 <AANLkTikkro-_9pv5uJ4+SqYh9Fr480_96Wh1Pv6Pvtez@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTikkro-_9pv5uJ4+SqYh9Fr480_96Wh1Pv6Pvtez@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 17, 2011 at 01:04:14PM +0800, Cypher Wu wrote:
>>
>> Have you turned CONFIG_LOCKDEP on?
>>
>> I think Eric already converted that rwlock into RCU lock, thus
>> this problem should disappear. Could you try a new kernel?
>>
>> Thanks.
>>
>
>I haven't turned CONFIG_LOCKDEP on for test since I didn't get too
>much information when we tried to figured out the former deadlock.
>
>IGMP used read_lock() instead of read_lock_bh() since usually
>read_lock() can be called recursively, and today I've read the
>implementation of MIPS, it's should also works fine in that situation.
>The implementation of TILEPro cause problem since after it use TNS set
>the lock-val to 1 and hold the original value and before it re-set
>lock-val a new value, it a race condition window.
>

I see no reason why you can't call read_lock_bh() recursively,
read_lock_bh() is roughly equalent to local_bh_disable() + read_lock(),
both can be recursive.

But I may miss something here. :-/
