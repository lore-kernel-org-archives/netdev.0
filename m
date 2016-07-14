From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [RFC PATCH v3] net: sched: convert qdisc linked list to
 hashtable
Date: Thu, 14 Jul 2016 16:14:58 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1607141612560.24757@cbobk.fhfr.pm>
References: <201607120341.UDv5wy6R%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201607120341.UDv5wy6R%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ added CCs ]

On Tue, 12 Jul 2016, kbuild test robot wrote:

> Hi,
> 
> [auto build test ERROR on net/master]
> [also build test ERROR on v4.7-rc7 next-20160711]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Jiri-Kosina/net-sched-convert-qdisc-linked-list-to-hashtable/20160711-220527
> config: arm-tct_hammer_defconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 5.3.1-8) 5.3.1 20160205
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All errors (new ones prefixed by >>):
> 
>    net/built-in.o: In function `dev_activate':
> >> wext-proc.c:(.text+0x38544): undefined reference to `qdisc_hash_add'

This issue is be there even without my patch (but with qdisc_list_add 
instead), isn't it?

The problem is that sch_generic.c (where dev_activate() is) is being 
compiled everytime CONFIG_NET is set, but sch_api.c (where 
qdisc_list_add() is defined) only when CONFIG_NET_SCHED is set (and there 
is no stub for !CONFIG_NET_SCHED case).

-- 
Jiri Kosina
SUSE Labs
