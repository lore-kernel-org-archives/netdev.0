From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 03/10] stmmac: sanitize the rx coe and add the type-1
 csum
Date: Tue, 03 Apr 2012 15:03:07 +0200
Message-ID: <4F7AF50B.3030708@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com> <1332493721-28309-4-git-send-email-peppe.cavallaro@st.com> <4F6D921F.10400@st.com> <4F79887A.50804@st.com> <4F79D13F.6020609@st.com> <4F7A9D7E.8080007@st.com> <4F7AAD4B.1010606@st.com>
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
To: deepaksi <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:59941 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753203Ab2DCNEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 09:04:32 -0400
In-Reply-To: <4F7AAD4B.1010606@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2012 9:56 AM, deepaksi wrote:
> Ciao Peppe,
> 
> On 4/3/2012 12:19 PM, Giuseppe CAVALLARO wrote:
>>
>> [snip]
>>> reset.
>> Previously, the stmmac called the dwmac1000_rx_coe_supported to verify
>> it could do the CSUM in Hw. If true the driver used the type 2 by
>> default.
>>
>> I've voluntarily removed this function because not necessary anymore.
>> In fact, YOU improved the rx_coe from the platform. If it is passed as
>> STMMAC_RX_COE_NONE then it means the driver is not able to perform any
>> csum for the incoming frames. This is actually used on old gmac/mac
>> cores. In new cores, the HW cap register will be used to manage and fix
>> this logic.
>> I could restore the core you are mentioning  but just to do another
>> safety check at run-time in case of the user provided a broken setting
>> from the platform and there is not the HW cap register. Hmm, I do not
>> know if this actually could help indeed... just an extra check IMHO.
> 
> These are the updates required in the code.
> 
> In function dwmac1000_core_init(), you may need to set the IPC bit based
> on the fact that
> if rx_coe has been setup through the platform code.
> This bit set is a must for the checksum offload to be enabled. Rest of
> the code looks good.
> 

Great Deepak,
sorry I had not understood your good question and thx for you call.
I was wrong and the IPC Checksum Offload has to be set in the MAC
Configuration Register (*).

static int dwmac1000_rx_coe_supported(void __iomem *ioaddr)
{
    u32 value = readl(ioaddr + GMAC_CONTROL);  |
                                               |==> :-) (*)
    value |= GMAC_CONTROL_IPC;                 |
    writel(value, ioaddr + GMAC_CONTROL);      |

    NOTE ===>>> I'm going to remove the extra check below because
                useless as I had told in my previous email.
                Is it ok for you? Let me know.

    value = readl(ioaddr + GMAC_CONTROL);

    return !!(value&  GMAC_CONTROL_IPC);
}


I'll rework it and re-send all the patches with this fix soon.

ciao
Peppe

> Deepak
> 
> 
> 
> 
> 
>>> I hope this clears the things a bit. Sorry for the miscommunication.
>> No problem for the miscommunication ;-)
>>
>> Let me know
>> Ciao
>> Peppe
>>
>>> Rgds
>>> Deepak
>>>
>>>
>>>
>>>
>>>
>>>
>>>>> Regards
>>>>> Deepak
>>>>>
>>>> .
>>>>
>>>
>> .
>>
> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
