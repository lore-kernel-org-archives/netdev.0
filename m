From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] GMAC: fix simple_return.cocci warnings
Date: Mon, 05 Jan 2015 23:26:20 -0800
Message-ID: <1420529180.2652.31.camel@perches.com>
References: <201501030822.7cG5bXrm%fengguang.wu@intel.com>
	 <20150103002526.GA15863@waimea.lkp.intel.com>
	 <1420246005.23591.7.camel@perches.com>
	 <20150104.222022.55122203599464788.davem@davemloft.net>
	 <54AB8B23.3080303@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, fengguang.wu@intel.com,
	kbuild-all@01.org, peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Roger <roger.chen@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0182.hostedemail.com ([216.40.44.182]:59372 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750921AbbAFH0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 02:26:24 -0500
In-Reply-To: <54AB8B23.3080303@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-01-06 at 15:13 +0800, Roger wrote:
> What should I do now?

I think it would be better to change
"int gmac_clk_enable" to "void gmac_clk_enable"
(it always returns 0)

This function should simply call gmac_clk_enable
and return 0;

> >>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> >>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
> >>> @@ -422,11 +422,7 @@ static int rk_gmac_init(struct platform_
> >>>   	if (ret)
> >>>   		return ret;
> >>>   
> >>> -	ret = gmac_clk_enable(bsp_priv, true);
> >>> -	if (ret)
> >>> -		return ret;
> >>> -
> >>> -	return 0;
> >>> +	return gmac_clk_enable(bsp_priv, true);
> >> I think this change is not particularly better.
> >>
> >> When the pattern is multiply repeated like:
> >   ...
> >> I think it's better to not change the last
> >> test in the sequence just to minimize overall
> >> line count.
> > I think it's a wash and that both ways are about the same to me.
> >
> > I won't apply this, sorry.
