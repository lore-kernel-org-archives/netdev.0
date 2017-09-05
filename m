From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: 915f3e3f76 ("mac80211_hwsim: Replace bogus hrtimer clockid"):
 BUG: kernel reboot-without-warning in test stage
Date: Tue, 5 Sep 2017 18:41:04 +0200
Message-ID: <20170905164103.tkrhxzca4b5ulps2@breakpoint.cc>
References: <59ade247.WzhbxWeytBOa6Xu4%fengguang.wu@intel.com>
 <alpine.DEB.2.20.1709050910150.1900@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, wfg@linux.intel.com
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1709050910150.1900@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-09-05 09:12:40 [+0200], Thomas Gleixner wrote:
> Sorry, no. That bisect is completely bogus. The commit in question merily
> replaces the unsupported clockid with a valid one.

The bisect is correct. It just has problems to express itself properly. So
the table says:

| WARNING:at_kernel/time/hrtimer.c:#hrtimer_init  | 7   |     |    |   |                                                                                
| BUG:kernel_reboot-without-warning_in_test_stage | 0   | 12  | 6  | 6 |                                                                                

which means _before_ your commit it counted a warning in hrtimer_init()
(an unsupported clock id was used). With your commit, the warning was
gone and I *think* the userland then printed
"BUG:kernel_reboot-without-warning_in_test_stage" because it had no
warning.
It seems that the bot learned to live with that warning which was around
for more than three years. Now that you removed it, it seems to be a
mistake to do so because nobody complained about it so far.

> Thanks,
> 
> 	tglx

Sebastian
