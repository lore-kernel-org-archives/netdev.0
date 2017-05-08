From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: Re: [PATCH] drivers: net: wimax: i2400m: i2400m-usb: Use time_after
 for time comparison
Date: Mon, 8 May 2017 16:27:14 -0700
Message-ID: <5ad8948b-4262-37d5-316d-f9c5f37f1e09@oracle.com>
References: <1494262682-5401-1-git-send-email-karim.eshapa@gmail.com>
 <20170508.172618.676839687841750049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, karim.eshapa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48534 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdEHX1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 19:27:19 -0400
In-Reply-To: <20170508.172618.676839687841750049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/17 2:26 PM, David Miller wrote:
> From: Karim Eshapa <karim.eshapa@gmail.com>
> Date: Mon,  8 May 2017 18:58:02 +0200
>
>> diff --git a/drivers/net/wimax/i2400m/i2400m-usb.h b/drivers/net/wimax/i2400m/i2400m-usb.h
>> index 649ecad..6fc941c 100644
>> --- a/drivers/net/wimax/i2400m/i2400m-usb.h
>> +++ b/drivers/net/wimax/i2400m/i2400m-usb.h
>> @@ -131,7 +131,7 @@ static inline int edc_inc(struct edc *edc, u16 max_err, u16 timeframe)
>>  	unsigned long now;
>>
>>  	now = jiffies;
>> -	if (now - edc->timestart > timeframe) {
>> +	if (time_after(now - edc->timestart, (unsigned long)timeframe)) {
>
> This is far from correct.
>
> time_after() compares two "jiffies" timestamp values.  The second
> argument here is not a jiffies timestamp value.
>

Perhaps, what is needed here is:

+	if (time_after(jiffies, edc->timestart + timeframe)) {

where in 'timeframe' is set in HZ in all the callers I checked (for the most 
part it is set to EDC_ERROR_TIMEFRAME which is 1HZ).

~Girish
