From: Prashant <prashant@broadcom.com>
Subject: Re: [PATCH net-next] tg3: Override clock, link aware and link idle
 mode during NVRAM dump
Date: Sat, 24 May 2014 01:04:50 -0700
Message-ID: <538052A2.1060700@broadcom.com>
References: <1400864084-27118-1-git-send-email-prashant@broadcom.com> <20140524.001739.1276621872731687446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:34281 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbaEXIEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 04:04:52 -0400
In-Reply-To: <20140524.001739.1276621872731687446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 5/23/2014 9:17 PM, David Miller wrote:
> From: Prashant Sreedharan <prashant@broadcom.com>
> Date: Fri, 23 May 2014 09:54:44 -0700
>
>> +		if (cpmu_val & (CPMU_CTRL_LINK_AWARE_MODE |
>> +				CPMU_CTRL_LINK_IDLE_MODE)) {
>> +
>
> Please remove this empty line.
Ok
>
>> +			tw32(TG3_CPMU_CTRL, cpmu_val &
>> +			     ~(CPMU_CTRL_LINK_AWARE_MODE |
>> +			       CPMU_CTRL_LINK_IDLE_MODE));
>
> This is not indented correctly.
>
> The ~() expression is part of the "cpum_val &", it's not
> another separate argument to tw32().
>
> Therefore ~() should be indented to the column cpum_val starts
> at.
>
Will fix indentation.
>> +		if (need_resched()) {
>> +			if (signal_pending(current)) {
>> +				eeprom->len += i;
>> +				ret = -EINTR;
>> +				goto eeprom_done;
>
> Why are you incrementing eeprom->len when you break out of the
> loop due to a signal?  You didn't read that extra byte.
>
eeprom->len is discarded by caller if a failure is returned.
I will resend the patch after incorporating comments and add your 
Reviewed-by. Thanks.
