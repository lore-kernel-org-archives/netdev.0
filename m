From: David Miller <davem@davemloft.net>
Subject: Re: [TG3]: Fix 2nd ifup failure on 5752M.
Date: Fri, 03 Nov 2006 01:01:21 -0800 (PST)
Message-ID: <20061103.010121.85418862.davem@davemloft.net>
References: <1162501349.3700.3.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6286
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752637AbWKCJBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 04:01:18 -0500
To: mchan@broadcom.com
In-Reply-To: <1162501349.3700.3.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 02 Nov 2006 13:02:29 -0800

> [TG3]: Fix 2nd ifup failure on 5752M.
> 
> This fixes a bug reported in:
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=7438
> 
> tg3_close() turns off the PHY if WoL and ASF are both disabled.  On
> the next tg3_open(), some devices such as the 5752M will not be
> brought up correctly without a PHY reset early in the reset sequence.
> The PHY clock is needed for some internal MAC blocks to function
> correctly.
> 
> This problem is fixed by always resetting the PHY early in
> tg3_reset_hw() when it is called from tg3_open() or tg3_resume().
> tg3_setup_phy() can then be called later in the sequence without the
> reset_phy parameter set to 1, since the PHY reset is already done.
> 
> Update version to 3.68.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks a lot Michael.
