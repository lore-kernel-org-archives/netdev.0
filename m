From: =?utf-8?B?TWljaGHFgiBLxJlwaWXFhA==?= <kernel@kempniu.pl>
Subject: Re: [PATCH 2/2] net: rfkill: Add rfkill-any LED trigger
Date: Thu, 1 Dec 2016 21:08:04 +0100
Message-ID: <20161201200804.GA3872@kmp-mobile.hq.kempniu.pl>
References: <20161130120317.11851-2-kernel@kempniu.pl>
 <201612020131.aDbI7Mq9%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: kbuild-all@01.org, Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: kbuild test robot <lkp@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201612020131.aDbI7Mq9%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi Michał,
> 
> [auto build test ERROR on mac80211-next/master]
> [also build test ERROR on v4.9-rc7 next-20161201]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Micha-K-pie/net-rfkill-Cleanup-error-handling-in-rfkill_init/20161202-002119
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git master
> config: i386-randconfig-x004-201648 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>    net/rfkill/core.c: In function 'rfkill_set_block':
> >> net/rfkill/core.c:354:2: error: implicit declaration of function '__rfkill_any_led_trigger_event' [-Werror=implicit-function-declaration]
>      __rfkill_any_led_trigger_event();
>      ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>    net/rfkill/core.c: In function 'rfkill_init':
>    net/rfkill/core.c:1349:1: warning: label 'error_led_trigger' defined but not used [-Wunused-label]
>     error_led_trigger:
>     ^~~~~~~~~~~~~~~~~
>    At top level:
>    net/rfkill/core.c:243:13: warning: 'rfkill_any_led_trigger_unregister' defined but not used [-Wunused-function]
>     static void rfkill_any_led_trigger_unregister(void)
>                 ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>    net/rfkill/core.c:238:12: warning: 'rfkill_any_led_trigger_register' defined but not used [-Wunused-function]
>     static int rfkill_any_led_trigger_register(void)
>                ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>    cc1: some warnings being treated as errors
> 
> vim +/__rfkill_any_led_trigger_event +354 net/rfkill/core.c
> 
>    348		rfkill->state &= ~RFKILL_BLOCK_SW_SETCALL;
>    349		rfkill->state &= ~RFKILL_BLOCK_SW_PREV;
>    350		curr = rfkill->state & RFKILL_BLOCK_SW;
>    351		spin_unlock_irqrestore(&rfkill->lock, flags);
>    352	
>    353		rfkill_led_trigger_event(rfkill);
>  > 354		__rfkill_any_led_trigger_event();
>    355	
>    356		if (prev != curr)
>    357			rfkill_event(rfkill);

Thanks, these are obviously all valid concerns.  Sorry for being sloppy
with the ifdefs.  If I get positive feedback on the proposed feature
itself, all these issues (and the warning pointed out in the other
message) will be resolved in v2.

-- 
Best regards,
Michał Kępień
