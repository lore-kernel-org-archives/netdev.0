From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 14:28:11 +0200
Message-ID: <49E7245B.10208@trash.net>
References: <49E64C91.5020708@cosmosbay.com>	<20090415.164811.19905145.davem@davemloft.net>	<20090415170111.6e1ca264@nehalam> <20090415.170539.34899625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dada1@cosmosbay.com,
	jeff.chua.linux@gmail.com, paulmck@linux.vnet.ibm.com,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090415.170539.34899625.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 15 Apr 2009 17:01:11 -0700
> 
>> The counters are the bigger problem, otherwise we could just free table
>> info via rcu.  Do we really have to support: replace where the counter
>> values coming out to user space are always exactly accurate, or is it
>> allowed to replace a rule and maybe lose some counter ticks (worst case
>> NCPU-1).
> 
> I say this case doesn't matter until someone can prove that it's
> any different from the IPTABLES replace operation system call
> executing a few microseconds earlier or later.
> 
> There really is no difference, and we're making complexity out of
> nothing just to ensure something which isn't actually guarenteed right
> now.

Actually I believe it does work right now. Userspace maps the old
counter values to the replacement rules and the kernel adds them
up, so in the end we currently should always have accurate counters,
independant of the exact time when a replacement took place.

