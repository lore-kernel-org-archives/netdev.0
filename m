From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Fix build error caused by broken PCH_PTP module
 dependency.
Date: Thu, 27 Sep 2012 18:09:42 -0400 (EDT)
Message-ID: <20120927.180942.969924012897168294.davem@davemloft.net>
References: <506009A4.8000202@linux.intel.com>
	<5060F97F.3040809@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tshimizu818@gmail.com,
	linux-kernel@vger.kernel.org, haicheng.lee@gmail.com
To: haicheng.li@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5060F97F.3040809@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Tue, 25 Sep 2012 08:23:27 +0800

> From 898e3214b3406c620571cedf704719784b0df049 Mon Sep 17 00:00:00 2001
> From: Haicheng Li <haicheng.li@linux.intel.com>
> Date: Mon, 24 Sep 2012 15:52:30 +0800
> Subject: [PATCH 1/2] Fix build error caused by broken PCH_PTP module
> dependency.
> 
> The .config is:
>         CONFIG_PCH_GBE=y
>         CONFIG_PCH_PTP=y
>         CONFIG_PTP_1588_CLOCK=m
> 
> The build error:

Your patch submissions are of a very low quality.

And the main reason is that you microscopically look at problems and
do not investigate how the same thing might be handled elsewhere.

Therefore you will never become accustomed to the proper way problems
are fixed, and the proper way to submit patches.

Look at how other people submit patches, do any other patch submissions
look like your's having all of this metadata in the message body:

> From 898e3214b3406c620571cedf704719784b0df049 Mon Sep 17 00:00:00 2001
> From: Haicheng Li <haicheng.li@linux.intel.com>
> Date: Mon, 24 Sep 2012 15:52:30 +0800
> Subject: [PATCH 1/2] Fix build error caused by broken PCH_PTP module
> dependency.

No, nobody else does this.

As for this specific patch:

> -	depends on PTP_1588_CLOCK_PCH
> +	depends on PTP_1588_CLOCK_PCH = PCH_GBE

This is not the correct way to ensure that the module'ness of one
config option meets the module'ness requirements of another.

The correct way is to say something like "&& (PCH_GBE || PCH_GBE=n)"
