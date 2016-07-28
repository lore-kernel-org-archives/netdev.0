From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v4] net: sched: convert qdisc linked list to hashtable
Date: Thu, 28 Jul 2016 09:53:55 -0700
Message-ID: <CAM_iQpWjES+zBJZvPgOHLDUQxeNwo4raapTYjGRT=nhHsoom7w@mail.gmail.com>
References: <201607281957.yJSK4rUm%fengguang.wu@intel.com> <alpine.LNX.2.00.1607281317350.24757@cbobk.fhfr.pm>
 <20160728125312.GB25433@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Kosina <jikos@kernel.org>, kbuild-all@01.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Fengguang Wu <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160728125312.GB25433@wfg-t540p.sh.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 28, 2016 at 5:53 AM, Fengguang Wu <lkp@intel.com> wrote:
> On Thu, Jul 28, 2016 at 01:18:27PM +0200, Jiri Kosina wrote:
>> This issue is be there even without my patch (but with qdisc_list_add
>> instead), isn't it?
>
>
> Yes it looks so, this number happens in a number of places:
>
> dns_query.c:(.text+0x39b84): undefined reference to `qdisc_hash_add'
> include/linux/netdevice.h:1935: undefined reference to `qdisc_hash_add'
> net/core/netevent.c:31: undefined reference to `qdisc_hash_add'
> net/sched/sch_generic.c:789: undefined reference to `qdisc_hash_add'
> sch_generic.c:(.text+0x33487): undefined reference to `qdisc_hash_add'
> switchdev.c:(.text+0x3bf58): undefined reference to `qdisc_hash_add'
> sysctl_net.c:(.text+0x31f70): undefined reference to `qdisc_hash_add'
> (.text.dev_activate+0x228): undefined reference to `qdisc_hash_add'
> (.text+0x37d0b): undefined reference to `qdisc_hash_add'
> wext-proc.c:(.text+0x390a8): undefined reference to `qdisc_hash_add'
>
>> The problem is that sch_generic.c (where dev_activate() is) is being
>> compiled everytime CONFIG_NET is set, but sch_api.c (where
>> qdisc_list_add() is defined) only when CONFIG_NET_SCHED is set (and there
>> is no stub for !CONFIG_NET_SCHED case).
>
>
> So it looks like a more general problem than specific to this patch.

Agreed. I can send a patch if Jiri doesn't. ;)
