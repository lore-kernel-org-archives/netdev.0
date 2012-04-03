From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 03/10] stmmac: sanitize the rx coe and add the type-1
 csum
Date: Tue, 03 Apr 2012 08:49:34 +0200
Message-ID: <4F7A9D7E.8080007@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com> <1332493721-28309-4-git-send-email-peppe.cavallaro@st.com> <4F6D921F.10400@st.com> <4F79887A.50804@st.com> <4F79D13F.6020609@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
	spear-devel <spear-devel@list.st.com>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Viresh KUMAR <viresh.kumar@st.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Deepak SIKRI <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:33346 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751353Ab2DCGvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 02:51:01 -0400
In-Reply-To: <4F79D13F.6020609@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Deepak,

On 4/2/2012 6:18 PM, Deepak SIKRI wrote:
> On 4/2/2012 4:37 PM, Giuseppe CAVALLARO wrote:
[snip]
>> I've not clear at all your question.
>> The driver well uses the rx_coe as briefly described below:
>>
>> probe funct
>>    |__ hw_init
>>           |_ check the RX type from HW cap reg
>>                   |__ Override the rx_coe if required
>>
>> After that the rx_coe is used and passed to the core as expected.
>> In case of there is no HW cap register so the rx_coe from platform will
>> be used.
>>
>> Peppe
> 
> In the same patch, this portion of the code has been removed.
> 
> -static int dwmac1000_rx_coe_supported(void __iomem *ioaddr)
> -{
> -    u32 value = readl(ioaddr + GMAC_CONTROL);
> -
> -    value |= GMAC_CONTROL_IPC;
> -    writel(value, ioaddr + GMAC_CONTROL);
> -
> -    value = readl(ioaddr + GMAC_CONTROL);
> -
> -    return !!(value&  GMAC_CONTROL_IPC);
> -}
> 
> Earlier this was taking care of setting the IP Checksum offloading feature
> in case its available. This code has to be present, as I do not see any
> other location where the IPC bit is being programmed.
> 
> Also, the location of setting the IPC should be post the mac has been
> reset.

Previously, the stmmac called the dwmac1000_rx_coe_supported to verify
it could do the CSUM in Hw. If true the driver used the type 2 by default.

I've voluntarily removed this function because not necessary anymore.
In fact, YOU improved the rx_coe from the platform. If it is passed as
STMMAC_RX_COE_NONE then it means the driver is not able to perform any
csum for the incoming frames. This is actually used on old gmac/mac
cores. In new cores, the HW cap register will be used to manage and fix
this logic.
I could restore the core you are mentioning  but just to do another
safety check at run-time in case of the user provided a broken setting
from the platform and there is not the HW cap register. Hmm, I do not
know if this actually could help indeed... just an extra check IMHO.

> 
> I hope this clears the things a bit. Sorry for the miscommunication.

No problem for the miscommunication ;-)

Let me know
Ciao
Peppe

> 
> Rgds
> Deepak
> 
> 
> 
> 
> 
> 
>>> Regards
>>> Deepak
>>>
>> .
>>
> 
> 
