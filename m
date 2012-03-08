From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 2/4] net: ethtool: add the EEE support
Date: Thu, 08 Mar 2012 16:14:10 +0100
Message-ID: <4F58CCC2.1060304@st.com>
References: <4F4E4D4B.3040909@st.com>  <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>  <1331022494-12891-3-git-send-email-peppe.cavallaro@st.com> <1331052982.2333.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	rayagond@vayavyalabs.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:37021 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755238Ab2CHPOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 10:14:48 -0500
In-Reply-To: <1331052982.2333.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben

On 3/6/2012 5:56 PM, Ben Hutchings wrote:
> On Tue, 2012-03-06 at 09:28 +0100, Giuseppe CAVALLARO wrote:
>> This patch adds two new functions to detect if Energy-Efficient
>> Ethernet (EEE) is supported and the way to enable/disable it.
> [...]
> 
> You haven't fixed any of the problems in the previous version of this
> patch.

Yes you are right,  sorry :-(

Below there is what you suggested and inline my comments.

Welcome advice!

On 2/29/2012 6:00 PM, Ben Hutchings wrote:

> It is certainly necessary to distinguish:
> a. PHY is advertising EEE
> from
> b. Link partner is advertising EEE
> or
> c. EEE will be used (= a && b)

you are perfectly right and indeed I wanted to do that.

> I haven't had anything to do with PHY drivers for a while but it looks
> like you should be able to map MDIO register 3.20 to supported flags,
> 7.60 to advertising and 7.61 to lp_advertising.

I have added a function named:

    phy_check_eee

For example, the stmmac driver (only if its HW core supports the EEE
feature) calls the phy_check_eee to understand if the the points a) and
b) above are satisfied.

On the Ethtool side, within the driver the .get_eee will pass to the
user-space if the EEE is used (just point c).
The .set_eee should used to force the MAC to disable/enable the EEE (if
actually supported by MAC+PHY).
I had added this option because the Synopsys GMAC manages the TX LPI
path through a SW timer :-( that in this case can be disabled via ethtool.
Indeed, no action should be taken by the user for the PHY side.
The only thing that could be changed is the clock stop enable bit (3.0.10).

What do you think?

Peppe

>
> Even if your particular device doesn't support these MDIO registers,
> other devices will.  So I think you should define the flags and then if
> you don't have that fine control you should check in your set_settings
> implementation that the advertising value either has all the EEE mode
> flags clear or has all the modes the hardware supports set.
>
> Ben.
>




> Ben.
> 
