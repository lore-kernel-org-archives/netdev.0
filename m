From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Fri, 12 Mar 2010 15:56:03 +0800
Message-ID: <2375c9f91003112356g1b4164e4pb5f63f0e0e2f310a@mail.gmail.com>
References: <2375c9f91003110205v1d7f00bfk89472cb11bd985d3@mail.gmail.com>
	 <20100311134556.GA6344@linux.vnet.ibm.com>
	 <20100311161751.GA3804@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100311161751.GA3804@hack>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc'ing netdev)

On Fri, Mar 12, 2010 at 12:17 AM, Am=C3=A9rico Wang <xiyou.wangcong@gma=
il.com> wrote:
> On Thu, Mar 11, 2010 at 05:45:56AM -0800, Paul E. McKenney wrote:
>>On Thu, Mar 11, 2010 at 06:05:38PM +0800, Am=C3=A9rico Wang wrote:
>>> Hello, Paul and Peter,
>>>
>>> Attached is the lockdep warning that I triggered today.
>>>
>>> I am not sure if this is a bug of rcu lockdep, because I am
>>> testing my patch when this occurred. However, in the backtrace,
>>> there is none of the functions that I touched, weird.
>>>
>>> So, please help to check if this is a bug of rcu lockdep.
>>
>>This sort of thing is caused by acquiring the same lock with softirq
>>(AKA BH) blocked and not, which can result in self-deadlock.
>>
>>There was such a bug in the RCU lockdep stuff in -tip, but it has lon=
g
>>since been fixed. =C2=A0If you were seeing that bug, rcu_do_batch() w=
ould
>>be on the stack, which it does not appear to be.
>>
>>So does your patch involve the usbfs_mutex? =C2=A0Or attempt to manip=
ulate
>>vfs/fs state from withing networking softirq/BH context?
>>
>
> Nope, it is a patch for netpoll, nothing related with usb, nor vfs.
>

Ok, after decoding the lockdep output, it looks like that
netif_receive_skb() should call rcu_read_lock_bh() instead of rcu_read_=
lock()?
But I don't know if all callers of netif_receive_skb() are in softirq c=
ontext.

Paul, what do you think?

Thank you.
