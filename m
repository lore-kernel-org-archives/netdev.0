From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: 915f3e3f76 ("mac80211_hwsim: Replace bogus hrtimer clockid"):
 BUG: kernel reboot-without-warning in test stage
Date: Tue, 5 Sep 2017 21:30:40 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1709052129510.2393@nanos>
References: <59ade247.WzhbxWeytBOa6Xu4%fengguang.wu@intel.com> <alpine.DEB.2.20.1709050910150.1900@nanos> <20170905164103.tkrhxzca4b5ulps2@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: kernel test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, wfg@linux.intel.com
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:46716 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751863AbdIETax (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 15:30:53 -0400
In-Reply-To: <20170905164103.tkrhxzca4b5ulps2@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 5 Sep 2017, Sebastian Andrzej Siewior wrote:

> On 2017-09-05 09:12:40 [+0200], Thomas Gleixner wrote:
> > Sorry, no. That bisect is completely bogus. The commit in question merily
> > replaces the unsupported clockid with a valid one.
> 
> The bisect is correct. It just has problems to express itself properly. So
> the table says:
> 
> | WARNING:at_kernel/time/hrtimer.c:#hrtimer_init  | 7   |     |    |   |                                                                                
> | BUG:kernel_reboot-without-warning_in_test_stage | 0   | 12  | 6  | 6 |                                                                                
> 
> which means _before_ your commit it counted a warning in hrtimer_init()
> (an unsupported clock id was used). With your commit, the warning was
> gone and I *think* the userland then printed
> "BUG:kernel_reboot-without-warning_in_test_stage" because it had no
> warning.
> It seems that the bot learned to live with that warning which was around
> for more than three years. Now that you removed it, it seems to be a
> mistake to do so because nobody complained about it so far.

Thanks for the translation. I'll never learn to decode these reports.

       tglx
