From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH] driver:net:stmmac: Disable DMA store and forward mode if
 platform data force_sf_dma_mode is negative.
Date: Mon, 19 Aug 2013 15:31:13 +0800
Message-ID: <CAJxxZ0PZUYeFnfnHVNaVi=wx_YDiTmsUNCfNyR27=jSuBH+tzg@mail.gmail.com>
References: <1376552256-7421-1-git-send-email-sonic.adi@gmail.com>
	<5211B524.4030609@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	adi-buildroot-devel@lists.sourceforge.net,
	Sonic Zhang <sonic.zhang@analog.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:43198 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879Ab3HSHbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 03:31:14 -0400
Received: by mail-ob0-f172.google.com with SMTP id er7so4838792obc.17
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 00:31:13 -0700 (PDT)
In-Reply-To: <5211B524.4030609@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Giuseppe,

On Mon, Aug 19, 2013 at 2:03 PM, Giuseppe CAVALLARO
<peppe.cavallaro@st.com> wrote:
> Hello Sonic
>
>
> On 8/15/2013 9:37 AM, Sonic Zhang wrote:
>>
>> From: Sonic Zhang <sonic.zhang@analog.com>
>>
>> Some synopsys ip implementation doesn't support DMA store and forward
>> mode,
>> such as BF60x. So, define force_sf_dma_mode negative to use DMA thresholds
>> only.
>
>
> I think that you should not pass the force_sf_dma_mode platform field
> at all (and it doesn't make sense to force it as negative).
> To use the threshold you should reset tx_coe. In fact, your HW cannot
> perform the Hw csum if SF is not available.
> Note that, the HW cap register (if available) can override (set/reset)
>  tx_coe.

Even if I reset tx_coe, the SF mode is still set to RX DMA in current
stmmac_dma_operation_mode(). SF mode is not supported in both RX DMA
and TX DMA in Blackfin MAC.


>
> I tested, long time ago, this scenario on old mac w/o HW cap register
> and w/o SF.

Blackfin synopsys MAC IP has the HW cap register with tx_coe set to 1,
but the HW tx_coe doesn't really work. I have the other patch to
disable HW tx_coe in board file and override the HW cap register.

Regards,

Sonic

>
> let me know if it is ok
>
> I have just noticed that the no_csum_insertion could be removed and I'll
> provide a patch for it.
>
