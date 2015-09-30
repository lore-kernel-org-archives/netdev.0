From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Y2038] [PATCH 11/12] [RFC] ipv4: avoid timespec in timestamp computation
Date: Wed, 30 Sep 2015 14:39:15 +0200
Message-ID: <1730636.Jx4pBXKUvN@wuerfel>
References: <201509301917.PqwXFTFd%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: kbuild test robot <lkp@intel.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	John Stultz <john.stultz@linaro.org>, kbuild-all@01.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>
To: y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:53527 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470AbbI3Mjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 08:39:37 -0400
In-Reply-To: <201509301917.PqwXFTFd%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 30 September 2015 19:55:43 kbuild test robot wrote:
> Hi Arnd,
> 
> [auto build test results on v4.3-rc3 -- if it's inappropriate base, please ignore]
> 
> config: mn10300-asb2364_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout e1358094d427405462a47d6d2650458b689e55d9
>   # save the attached .config to linux build tree
>   make.cross ARCH=mn10300 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    kernel/built-in.o: In function `current_thread_info':
>    (___ksymtab_gpl+ktime_get_ms_since_midnight+0x0): undefined reference to `ktime_get_ms_since_midnight'
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    am33_2.0-linux-ld: Dwarf Error: mangled line number section.
>    net/built-in.o: In function `register_netevent_notifier':
> >> net/core/netevent.c:29: undefined reference to `ktime_get_ms_since_midnight'
> >> net/core/netevent.c:29: undefined reference to `ktime_get_ms_since_midnight'
>    net/core/netevent.c:17: undefined reference to `ktime_get_ms_since_midnight'

Thanks for the helpful report, I love the new feature of grabbing the patches
from the list.

Moreover, sorry for screwing up here, I changed the function name before
sending it out and only compiled the files individually but did not notice
that I only changed it in three out of four places because I did not
try to relink the kernel.

I'll send an updated version.

	Arnd
