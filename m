From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: Do full reset during ax88772_bind
Date: Fri, 07 Nov 2014 15:30:46 -0500 (EST)
Message-ID: <20141107.153046.1116308054532402400.davem@davemloft.net>
References: <1415288981-3862-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, m.stam@fugro.nl, emilgoode@gmail.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ckeepax@opensource.wolfsonmicro.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415288981-3862-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Date: Thu,  6 Nov 2014 15:49:41 +0000

> commit 3cc81d85ee01 ("asix: Don't reset PHY on if_up for ASIX 88772")
> causes the ethernet on Arndale to no longer function. This appears to
> be because the Arndale ethernet requires a full reset before it will
> function correctly, however simply reverting the above patch causes
> problems with ethtool settings getting reset.
> 
> It seems the problem is that the ethernet is not properly reset during
> bind, and indeed the code in ax88772_bind that resets the device is a
> very small subset of the actual ax88772_reset function. This patch uses
> ax88772_reset in place of the existing reset code in ax88772_bind which
> removes some code duplication and fixes the ethernet on Arndale.
> 
> It is still possible that the original patch causes some issues with
> suspend and resume but that seems like a separate issue and I haven't
> had a chance to test that yet.
> 
> Signed-off-by: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
> Tested-by: Riku Voipio <riku.voipio@linaro.org>
> ---
> 
> Hi,
> 
> I wasn't 100% sure which branch to base this off so I based it on Dave
> Miller's net-next branch, which seemed logical.

Since it fixes a regression that is upstream already, I'm applying this
to the net tree.

Thanks.
