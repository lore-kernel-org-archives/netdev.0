From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Sat, 13 Nov 2010 14:35:51 +0800
Message-ID: <20101113063551.GD3837@hack>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com> <1289489007.17691.1310.camel@edumazet-laptop> <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com> <20101112071323.GB5660@cr0.nay.redhat.com> <1289546874.17691.1774.camel@edumazet-laptop> <20101112081945.GA5949@cr0.nay.redhat.com> <AANLkTik-KDvc2fgH91vBHGT6vqxbZrv=9DoQknujPWy2@mail.gmail.com> <20101112091818.GB5949@cr0.nay.redhat.com> <AANLkTi=0Z1zVqCvYwKiQ8cUZoeD_rLgZ+C07GuFgA7E7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Yong Zhang <yong.zhang0@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Cypher Wu <cypher.w@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=0Z1zVqCvYwKiQ8cUZoeD_rLgZ+C07GuFgA7E7@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 12, 2010 at 07:06:47PM +0800, Cypher Wu wrote:
>>
>> Note, on Tile, it uses a little different algorithm.
>>
>
>It seems that rwlock on x86 and tile have different behavior, x86 use
>RW_LOCK_BIAS, when read_lock() it will test if the lock is 0, and if
>so then the read_lock() have to 'spinning', otherwise it dec the lock;
>when write_lock() tried it first check if lock is It seems that rwlock
>on x86 and tile have different behavior, x86 use RW_LOCK_BIAS and if
>so, set lock to 0 and continue, otherwise it will 'spinning'.
>I'm not very familiar with x86 architecture, but the code seems like
>working that way.

No, they should be the same, sorry I made a mistake in the above reply.

Although Tile uses shifts in implementation while x86 uses inc/dec,
the idea is same, either writers use higher bits and readers use
lower bits or vice-versa.

-- 
Live like a child, think like the god.
 
