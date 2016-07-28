From: Fengguang Wu <lkp@intel.com>
Subject: Re: [PATCH v4] net: sched: convert qdisc linked list to hashtable
Date: Thu, 28 Jul 2016 20:53:12 +0800
Message-ID: <20160728125312.GB25433@wfg-t540p.sh.intel.com>
References: <201607281957.yJSK4rUm%fengguang.wu@intel.com>
 <alpine.LNX.2.00.1607281317350.24757@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: kbuild-all@01.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1607281317350.24757@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 28, 2016 at 01:18:27PM +0200, Jiri Kosina wrote:
>On Thu, 28 Jul 2016, kbuild test robot wrote:
>
>> [auto build test ERROR on v4.7-rc7]
>> [also build test ERROR on next-20160728]
>> [cannot apply to net/master net-next/master ipsec-next/master]
>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>>
>> url:    https://github.com/0day-ci/linux/commits/Jiri-Kosina/net-sched-convert-qdisc-linked-list-to-hashtable/20160728-182303
>> config: i386-randconfig-s0-201630 (attached as .config)
>> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
>> reproduce:
>>         # save the attached .config to linux build tree
>>         make ARCH=i386
>>
>> All errors (new ones prefixed by >>):
>>
>>    net/built-in.o: In function `dev_activate':
>> >> (.text+0x37ccb): undefined reference to `qdisc_hash_add'
>
>Dear 0-day team,
>
>could you please check my question regarding this very build failure here?
>
>	lkml.kernel.org/r/alpine.LNX.2.00.1607141612560.24757@cbobk.fhfr.pm

Sorry I missed that. For your convenience, here is the answer to the
original email:

>This issue is be there even without my patch (but with qdisc_list_add
>instead), isn't it?

Yes it looks so, this number happens in a number of places:

dns_query.c:(.text+0x39b84): undefined reference to `qdisc_hash_add'
include/linux/netdevice.h:1935: undefined reference to `qdisc_hash_add'
net/core/netevent.c:31: undefined reference to `qdisc_hash_add'
net/sched/sch_generic.c:789: undefined reference to `qdisc_hash_add'
sch_generic.c:(.text+0x33487): undefined reference to `qdisc_hash_add'
switchdev.c:(.text+0x3bf58): undefined reference to `qdisc_hash_add'
sysctl_net.c:(.text+0x31f70): undefined reference to `qdisc_hash_add'
(.text.dev_activate+0x228): undefined reference to `qdisc_hash_add'
(.text+0x37d0b): undefined reference to `qdisc_hash_add'
wext-proc.c:(.text+0x390a8): undefined reference to `qdisc_hash_add'

>The problem is that sch_generic.c (where dev_activate() is) is being
>compiled everytime CONFIG_NET is set, but sch_api.c (where
>qdisc_list_add() is defined) only when CONFIG_NET_SCHED is set (and there
>is no stub for !CONFIG_NET_SCHED case).

So it looks like a more general problem than specific to this patch.

Thanks,
Fengguang
