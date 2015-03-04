From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: check IRQ availability early on probe
Date: Wed, 04 Mar 2015 15:44:12 -0500 (EST)
Message-ID: <20150304.154412.1886796464281085513.davem@davemloft.net>
References: <1425379604-24107-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vineet.Gupta1@synopsys.com, andriy.shevchenko@linux.intel.com,
	peppe.cavallaro@st.com, sonic.zhang@analog.com
To: Alexey.Brodkin@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425379604-24107-1-git-send-email-abrodkin@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Date: Tue,  3 Mar 2015 13:46:44 +0300

> Currently we're getting IRQs after lots of resources are already
> allocated:
>  * netdev
>  * clocks
>  * MDIO bus
> Also HW gets initialized by the time when checking IRQs as well.
> 
> Now there's a possibility for master interrupt controller to be not
> probed yet. This will lead to exit from GMAC probe routine with "-
> EPROBE_DEFER" and so deferred probe will hapen later on.
> 
> But since we exited the first GMAC probe without release of all
> allocated resources there could be conflicts on subsequent probes.
> 
> For example this is what happens for me:
 ...
> Essential fix is to check for IRQs availability as early as possible and
> then safely go to deferred probe if IRQs are not there yet.
> 
> Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Applied, thanks.
