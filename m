From: David Miller <davem@davemloft.net>
Subject: Re: [net:master 1/9] pch_gbe_main.c:(.text+0x510370): undefined
 reference to `pch_ch_control_write'
Date: Sat, 06 Oct 2012 09:22:07 -0400 (EDT)
Message-ID: <20121006.092207.1280541690613202532.davem@davemloft.net>
References: <20121006075954.GA29618@localhost>
	<50701EEC.7080805@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: haicheng.li@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50701EEC.7080805@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Sat, 06 Oct 2012 20:07:08 +0800

> The failure is due to the CONFIG_PPS is not set there, consequently
> CONFIG_PTP_1588_CLOCK can not be set as =y anyway.
> 
> So David's patch of "da1586461e53a4dd045738cce309ab488970f0ef [1/9]
> pch_gbe: Fix PTP dependencies" is buggy. Furthermore, I think using
> "selects" to resolve such dependency issue is not good idea as it
> won't visit the dependencies.
> 
> David, I would still suggest to take my original patch:
> https://lkml.org/lkml/2012/9/28/70
> 
> + depends on PTP_1588_CLOCK_PCH && (PCH_GBE=m || PTP_1588_CLOCK_PCH=y)
> 
> or simply like:

This is all very rediculous if you ask me.

Why should the user have to know a detail like the underlying
PTP chip type just to enable PTP on his networking card?

Because that is what you are making him do with your change.

Select removed the necessity of the user having to know these
things.
