From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 03/10] stmmac: sanitize the rx coe and add the type-1
 csum
Date: Tue, 3 Apr 2012 13:26:59 +0530
Message-ID: <4F7AAD4B.1010606@st.com>
References: <1332493721-28309-1-git-send-email-peppe.cavallaro@st.com> <1332493721-28309-4-git-send-email-peppe.cavallaro@st.com> <4F6D921F.10400@st.com> <4F79887A.50804@st.com> <4F79D13F.6020609@st.com> <4F7A9D7E.8080007@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Srinivas KANDAGATLA <srinivas.kandagatla@st.com>,
	spear-devel <spear-devel@list.st.com>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Viresh KUMAR <viresh.kumar@st.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:37739 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751353Ab2DCH6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 03:58:22 -0400
In-Reply-To: <4F7A9D7E.8080007@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ciao Peppe,

On 4/3/2012 12:19 PM, Giuseppe CAVALLARO wrote:
>
> [snip]
>> reset.
> Previously, the stmmac called the dwmac1000_rx_coe_supported to verify
> it could do the CSUM in Hw. If true the driver used the type 2 by default.
>
> I've voluntarily removed this function because not necessary anymore.
> In fact, YOU improved the rx_coe from the platform. If it is passed as
> STMMAC_RX_COE_NONE then it means the driver is not able to perform any
> csum for the incoming frames. This is actually used on old gmac/mac
> cores. In new cores, the HW cap register will be used to manage and fix
> this logic.
> I could restore the core you are mentioning  but just to do another
> safety check at run-time in case of the user provided a broken setting
> from the platform and there is not the HW cap register. Hmm, I do not
> know if this actually could help indeed... just an extra check IMHO.

These are the updates required in the code.

In function dwmac1000_core_init(), you may need to set the IPC bit based 
on the fact that
if rx_coe has been setup through the platform code.
This bit set is a must for the checksum offload to be enabled. Rest of 
the code looks good.

Deepak





>> I hope this clears the things a bit. Sorry for the miscommunication.
> No problem for the miscommunication ;-)
>
> Let me know
> Ciao
> Peppe
>
>> Rgds
>> Deepak
>>
>>
>>
>>
>>
>>
>>>> Regards
>>>> Deepak
>>>>
>>> .
>>>
>>
> .
>
