From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/3] stmmac: unify MAC and PHY configuration parameters
Date: Wed, 20 Jul 2011 07:33:16 +0200
Message-ID: <4E26689C.1090502@st.com>
References: <1311064684-20246-1-git-send-email-peppe.cavallaro@st.com> <20110719.115738.131562530013095617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stuart.menefy@st.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:57417 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751619Ab1GTFdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 01:33:44 -0400
In-Reply-To: <20110719.115738.131562530013095617.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

On 7/19/2011 8:57 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Tue, 19 Jul 2011 10:38:02 +0200
> 
>> Prior to this change, most PHY configuration parameters were passed
>> into the STMMAC device as a separate PHY device. As well as being
>> unusual, this made it difficult to make changes to the MAC/PHY
>> relationship.
>>
>> This patch moves all the PHY parameters into the MAC configuration
>> structure, mainly as a separate structure. This allows us to completly
>> ignore the MDIO bus attached to a stmmac if desired, and not create
>> the PHY bus. It also allows the stmmac driver to use a different PHY
>> from the one it is connected to, for example a fixed PHY or bit banging
>> PHY.
>>
>> Also derive the stmmac/PHY connection type (MII/RMII etc) from the
>> mode can be passed into <platf>_configure_ethernet.
>> STLinux kernel at git://git.stlinux.com/stm/linux-sh4-2.6.32.y.git
>> provides several examples how to use this new infrastructure (that
>> actually is easier to maintain and clearer).
>>
>> Signed-off-by: Stuart Menefy <stuart.menefy@st.com>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> 
> I find these changes confusing, because I can't see where these
> platform data objects are created that end up being used by
> the stmmac driver.
> 
> I'm concerned about this because if you're changing these data
> structures, you'll need to update also the code that creates
> these platform data objects.

You are right and indeed I wanted to provide some other patches to show
how to use the new infrastructure instead of adding the stlinux git
where our platforms that already use that.

> Finally, this patch needs to update Documentation/networking/stmmac.txt

Agree and sorry to have forgotten that.
I'll update the driver's documentation trying to add a valid example how
to use the new structures (taking as example stm devel).
After that I'll send the patches again.

At any rate, as I also do via email, I'm happy to support all guys that
are starting to use in the driver on several architectures (arm, sh, ppc).

This patch is useful because tidy-up the code and make easier the MDIO
part (also in case we use fixed_link etc.).

Thanks for your feedback.

Regards
Peppe

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

