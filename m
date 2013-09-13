From: Jun Chen <jun.d.chen@intel.com>
Subject: Re: [PATCH] Inet-hashtable: Change the range of sk->hash lock to
 avoid the race condition.
Date: Fri, 13 Sep 2013 05:47:23 -0400
Message-ID: <1379065643.3390.3.camel@chenjun-workstation>
References: <1379003549.12328.6.camel@chenjun-workstation>
	 <1378987204.24408.1.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jun Chen <jun.d.chen@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378987204.24408.1.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-12 at 05:00 -0700, Eric Dumazet wrote:
> On Thu, 2013-09-12 at 12:32 -0400, Jun Chen wrote:
> > When try to add node to list in __inet_hash_nolisten function, first get the
> > list and then to lock for using, but in extremeness case, others can del this
> > node before locking it, then the node should be null.So this patch try to lock
> > firstly and then get the list for using to avoid this race condition.
> 
> I suspect another bug. This should not happen.
> 
> Care to describe the problem you got ?
> 
> Thanks
> 
> 

Ok, I just got this call stack and no more info, pls help to look it.
thanks!

<1>[ 88.548263] BUG: unable to handle kernel NULL pointer dereference at
00000004
<1>[ 88.548490] IP: [] __inet_hash_nolisten+0xc1/0x140
<4>[ 88.548617] *pde = 00000000
<4>[ 88.549927] EIP is at __inet_hash_nolisten+0xc1/0x140
<4>[ 88.550008] EAX: 00000000 EBX: e08c0000 ECX: edf846e0 EDX: e08c0020
<4>[ 88.550055] ESI: c20213c0 EDI: edc12dc0 EBP: ce4bfdfc ESP: ce4bfde8
<4>[ 88.550137] DS: 007b ES: 007b FS: 00d8 GS: 003b SS: 0068
<4>[ 88.550184] CR0: 80050033 CR2: 00000004 CR3: 2b4ff000 CR4: 001007d0
<4>[ 88.550266] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
<4>[ 88.550346] DR6: ffff0ff0 DR7: 00000400
<0>[ 88.550392] Process WebViewCoreThre (pid: 2137, ti=ce4be000
task=eb193c80 task.ti=ce4be000)
<0>[ 88.551746] Call Trace:
<4>[ 88.551797] [] __inet_hash_connect+0x295/0x2d0
<4>[ 88.551883] [] inet_hash_connect+0x40/0x50
<4>[ 88.551932] [] ? inet_unhash+0x90/0x90
<4>[ 88.551981] [] ? __inet_lookup_listener+0x1b0/0x1b0
<4>[ 88.552067] [] tcp_v4_connect+0x247/0x4a0
<4>[ 88.552117] [] ? lock_sock_nested+0x3e/0x50
<4>[ 88.552205] [] inet_stream_connect+0xe2/0x290
<4>[ 88.552254] [] ? _copy_from_user+0x35/0x50
<4>[ 88.552342] [] sys_connect+0xb2/0xd0
<4>[ 88.552393] [] ? alloc_file+0x20/0xa0
<4>[ 88.552441] [] ? tcp_setsockopt+0x50/0x60
<4>[ 88.552525] [] ? fget_light+0x44/0xe0
<4>[ 88.552574] [] ? sock_common_setsockopt+0x27/0x40
<4>[ 88.552659] [] ? _copy_from_user+0x35/0x50
<4>[ 88.552708] [] sys_socketcall+0xab/0x2b0
<4>[ 88.552790] [] ? trace_hardirqs_on_thunk+0xc/0x10
<4>[ 88.552840] [] syscall_call+0x7/0xb
<4>[ 88.552923] [] ? mutex_trylock+0x30/0x140
