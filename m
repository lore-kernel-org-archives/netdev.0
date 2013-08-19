From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] driver:net:stmmac: Disable DMA store and forward mode
 if platform data force_sf_dma_mode is negative.
Date: Mon, 19 Aug 2013 09:45:24 +0200
Message-ID: <5211CD14.3080808@st.com>
References: <1376552256-7421-1-git-send-email-sonic.adi@gmail.com> <5211B524.4030609@st.com> <CAJxxZ0PZUYeFnfnHVNaVi=wx_YDiTmsUNCfNyR27=jSuBH+tzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog124.obsmtp.com ([207.126.144.157]:39804 "EHLO
	eu1sys200aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751028Ab3HSHpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 03:45:43 -0400
In-Reply-To: <CAJxxZ0PZUYeFnfnHVNaVi=wx_YDiTmsUNCfNyR27=jSuBH+tzg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/19/2013 9:31 AM, Sonic Zhang wrote:
> Hi Giuseppe,
>
> On Mon, Aug 19, 2013 at 2:03 PM, Giuseppe CAVALLARO
> <peppe.cavallaro@st.com> wrote:
>> Hello Sonic
>>
>>
>> On 8/15/2013 9:37 AM, Sonic Zhang wrote:
>>>
>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>>
>>> Some synopsys ip implementation doesn't support DMA store and forward
>>> mode,
>>> such as BF60x. So, define force_sf_dma_mode negative to use DMA thresholds
>>> only.
>>
>>
>> I think that you should not pass the force_sf_dma_mode platform field
>> at all (and it doesn't make sense to force it as negative).
>> To use the threshold you should reset tx_coe. In fact, your HW cannot
>> perform the Hw csum if SF is not available.
>> Note that, the HW cap register (if available) can override (set/reset)
>>   tx_coe.
>
> Even if I reset tx_coe, the SF mode is still set to RX DMA in current
> stmmac_dma_operation_mode(). SF mode is not supported in both RX DMA
> and TX DMA in Blackfin MAC.

yes this is true. the SF is always set for the RX path because I have
never had and known HW w/o RX csum (since the 209).

So I think the code could be improved to disable/enable the SF also for
the RX path.

>>
>> I tested, long time ago, this scenario on old mac w/o HW cap register
>> and w/o SF.
>
> Blackfin synopsys MAC IP has the HW cap register with tx_coe set to 1,
> but the HW tx_coe doesn't really work. I have the other patch to
> disable HW tx_coe in board file and override the HW cap register.

AFAIK the HW shouldn't be able to perform the csum in HW w/o SF.

Maybe, an easy way could be to use a new field to force the threshold
mode. This should also remove the csum in HW (IMO) and program the
DMA operation register.

Regards
Peppe

>
> Regards,
>
> Sonic
>
>>
>> let me know if it is ok
>>
>> I have just noticed that the no_csum_insertion could be removed and I'll
>> provide a patch for it.
>>
>
>
