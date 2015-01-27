From: Andy Green <andy.green@linaro.org>
Subject: Re: [PATCH 4/7] net: wireless: wcn36xx: introduce WCN36XX_HAL_AVOID_FREQ_RANGE_IND
Date: Wed, 28 Jan 2015 04:57:49 +0800
Message-ID: <CAAfg0W606C+=dkKRE1quaaeAUBg1nvy3L5+873F2=oAOT=Bm5w@mail.gmail.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051100.31866.37997.stgit@114-36-241-182.dynamic.hinet.net>
	<CAFSJ42ZydByi_u0auSGDx2A6_ObZGfjV7+kR_CzFYLORRHQ5wg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eugene Krasnikov <k.eugene.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:58957 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbbA0U54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:57:56 -0500
Received: by mail-qa0-f42.google.com with SMTP id dc16so13299995qab.1
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 12:57:56 -0800 (PST)
In-Reply-To: <CAFSJ42ZydByi_u0auSGDx2A6_ObZGfjV7+kR_CzFYLORRHQ5wg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 January 2015 at 04:01, Eugene Krasnikov <k.eugene.e@gmail.com> wrote:
> Do you know when is this message used? sounds important.

It's related to BT coexistance or radar... prima expects this payload with it

#define WLAN_HAL_MAX_AVOID_FREQ_RANGE           4

typedef PACKED_PRE struct PACKED_POST
{
   tANI_U32     startFreq;
   tANI_U32     endFreq;
}  tHalFreqRange, *tpHalFreqRange;

typedef PACKED_PRE struct PACKED_POST
{
   tANI_U32         avoidCnt;
   tHalFreqRange    avoidRange[WLAN_HAL_MAX_AVOID_FREQ_RANGE];

Basically wcn firmware can propose up to 4 frequency ranges to not use
for whatever reason... prima looks like it tries to disable channels
accordingly.

-Andy

> 2015-01-18 5:11 GMT+00:00 Andy Green <andy.green@linaro.org>:
>> WCN3620 firmware introduces a new async indication, we need to
>> add it as a known message type so we can accept it
>>
>> Signed-off-by: Andy Green <andy.green@linaro.org>
>> ---
>>  drivers/net/wireless/ath/wcn36xx/hal.h |    2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
>> index a1f1127..b947de0 100644
>> --- a/drivers/net/wireless/ath/wcn36xx/hal.h
>> +++ b/drivers/net/wireless/ath/wcn36xx/hal.h
>> @@ -345,6 +345,8 @@ enum wcn36xx_hal_host_msg_type {
>>         WCN36XX_HAL_DHCP_START_IND = 189,
>>         WCN36XX_HAL_DHCP_STOP_IND = 190,
>>
>> +       WCN36XX_HAL_AVOID_FREQ_RANGE_IND = 233,
>> +
>>         WCN36XX_HAL_MSG_MAX = WCN36XX_HAL_MSG_TYPE_MAX_ENUM_SIZE
>>  };
>>
>>
>
>
>
> --
> Best regards,
> Eugene
