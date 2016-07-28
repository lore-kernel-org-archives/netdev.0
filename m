From: Fengguang Wu <lkp@intel.com>
Subject: Re: [RFC PATCH v3] net: sched: convert qdisc linked list to hashtable
Date: Thu, 28 Jul 2016 20:51:57 +0800
Message-ID: <20160728125157.GA25433@wfg-t540p.sh.intel.com>
References: <201607120341.UDv5wy6R%fengguang.wu@intel.com>
 <alpine.LNX.2.00.1607141612560.24757@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1607141612560.24757@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jiri,

On Thu, Jul 14, 2016 at 04:14:58PM +0200, Jiri Kosina wrote:
>
>[ added CCs ]
>
>On Tue, 12 Jul 2016, kbuild test robot wrote:
>
>> Hi,
>>
>> [auto build test ERROR on net/master]
>> [also build test ERROR on v4.7-rc7 next-20160711]
>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>>
>> url:    https://github.com/0day-ci/linux/commits/Jiri-Kosina/net-sched-convert-qdisc-linked-list-to-hashtable/20160711-220527
>> config: arm-tct_hammer_defconfig (attached as .config)
>> compiler: arm-linux-gnueabi-gcc (Debian 5.3.1-8) 5.3.1 20160205
>> reproduce:
>>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>         chmod +x ~/bin/make.cross
>>         # save the attached .config to linux build tree
>>         make.cross ARCH=arm
>>
>> All errors (new ones prefixed by >>):
>>
>>    net/built-in.o: In function `dev_activate':
>> >> wext-proc.c:(.text+0x38544): undefined reference to `qdisc_hash_add'
>
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
