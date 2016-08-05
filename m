From: arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: Re: [v5.1] ucc_fast: Fix to avoid IS_ERR_VALUE abuses and dead code
 on 64bit systems.
Date: Fri, 5 Aug 2016 14:18:32 +0530
Message-ID: <57A452E0.10904@gmail.com>
References: <1470329563-5464-1-git-send-email-arvind.yadav.cs@gmail.com>
 <2376517.GXv6XVOdDd@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, leoli@freescale.com, qiang.zhao@freescale.com,
	viresh.kumar@linaro.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, scottwood@freescale.com,
	akpm@linux-foundation.org, linux@roeck-us.net
To: Arnd Bergmann <arnd@arndb.de>, linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36397 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759414AbcHEIsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 04:48:40 -0400
In-Reply-To: <2376517.GXv6XVOdDd@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Friday 05 August 2016 02:01 AM, Arnd Bergmann wrote:
> On Thursday, August 4, 2016 10:22:43 PM CEST Arvind Yadav wrote:
>> index df8ea79..ada9070 100644
>> --- a/include/soc/fsl/qe/ucc_fast.h
>> +++ b/include/soc/fsl/qe/ucc_fast.h
>> @@ -165,10 +165,12 @@ struct ucc_fast_private {
>>          int stopped_tx;         /* Whether channel has been stopped for Tx
>>                                     (STOP_TX, etc.) */
>>          int stopped_rx;         /* Whether channel has been stopped for Rx */
>> -       u32 ucc_fast_tx_virtual_fifo_base_offset;/* pointer to base of Tx
>> -                                                   virtual fifo */
>> -       u32 ucc_fast_rx_virtual_fifo_base_offset;/* pointer to base of Rx
>> -                                                   virtual fifo */
>> +       unsigned long ucc_fast_tx_virtual_fifo_base_offset;/* pointer to base of
>> +                                                           * Tx virtual fifo
>> +                                                           */
>> +       unsigned long ucc_fast_rx_virtual_fifo_base_offset;/* pointer to base of
>> +                                                           * Rx virtual fifo
>> +                                                           */
>>   #ifdef STATISTICS
>>          u32 tx_frames;          /* Transmitted frames counter. */
>>          u32 rx_frames;          /* Received frames counter (only frames
>>
> This change seems ok, but what about the other u32 variables in ucc_geth.c
> that get checked for IS_ERR_VALUE?
>
> 	Arnd
> I have send separate patch for ucc_geth ans ucc_slow.
> -Arvind
