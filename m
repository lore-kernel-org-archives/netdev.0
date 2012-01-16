From: Glauber Costa <glommer@parallels.com>
Subject: Re: recvmsg sleeping from invalid context
Date: Mon, 16 Jan 2012 11:21:14 +0400
Message-ID: <4F13CFEA.9010406@parallels.com>
References: <20120113182401.GA25885@redhat.com> <20120113.102712.600185688659703015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davej@redhat.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120113.102712.600185688659703015.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/13/2012 10:27 PM, David Miller wrote:
> From: Dave Jones<davej@redhat.com>
> Date: Fri, 13 Jan 2012 13:24:01 -0500
>
>> getting a ton of these on the latest head (099469502f62fbe0d7e4f0b83a2f22538367f734)
>>
>> BUG: sleeping function called from invalid context at mm/memory.c:3905
>> in_atomic(): 0, irqs_disabled(): 0, pid: 1067, name: NetworkManager
>> INFO: lockdep is turned off.
>> Pid: 1067, comm: NetworkManager Not tainted 3.2.0+ #22
>> Call Trace:
>>   [<ffffffff81099415>] __might_sleep+0x145/0x200
>>   [<ffffffff811752a4>] might_fault+0x34/0xb0
>>   [<ffffffff81551555>] ? sock_def_readable+0x25/0x1a0
>>   [<ffffffff8155c387>] put_cmsg+0x77/0x120
>>   [<ffffffff8159379c>] netlink_recvmsg+0x35c/0x480
>>   [<ffffffff8155201a>] ? sock_update_classid+0x9a/0x260
>>   [<ffffffff81552052>] ? sock_update_classid+0xd2/0x260
>>   [<ffffffff81549fbd>] sock_recvmsg+0x11d/0x140
>>   [<ffffffff811752c3>] ? might_fault+0x53/0xb0
>>   [<ffffffff8117530c>] ? might_fault+0x9c/0xb0
>>   [<ffffffff811752c3>] ? might_fault+0x53/0xb0
>>   [<ffffffff8154b1b3>] __sys_recvmsg+0x153/0x2d0
>>   [<ffffffff811bc39a>] ? fget_light+0x5a/0x470
>>   [<ffffffff8109fd11>] ? get_parent_ip+0x11/0x50
>>   [<ffffffff816ac23d>] ? sub_preempt_count+0x9d/0xd0
>>   [<ffffffff811bc43b>] ? fget_light+0xfb/0x470
>>   [<ffffffff811bc39a>] ? fget_light+0x5a/0x470
>>   [<ffffffff8154e2e9>] sys_recvmsg+0x49/0x90
>>   [<ffffffff816b00e9>] system_call_fastpath+0x16/0x1b
>
> Sigh, I suspect the new socket memcg code, which I didn't want to
> even apply in the first place. :-/
>
> Glauber, please fix this.

I really don't see how this can be related to sock memcg at all.
Nothing in the stack trace points to it.

You probably got this impression by "sock_update_classid", which has
a naming similar to the ones I used to update some sockets attributes, 
but are something else entirely.
