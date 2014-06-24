From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next 6/6] amd-xgbe: Resolve checkpatch warning about
 sscanf usage
Date: Tue, 24 Jun 2014 17:44:18 -0500
Message-ID: <53A9FF42.2090502@amd.com>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
	 <20140624211935.20681.85586.stgit@tlendack-t1.amdoffice.net>
 <1403647225.29061.64.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0204.outbound.protection.outlook.com ([207.46.163.204]:32700
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752683AbaFXWov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 18:44:51 -0400
In-Reply-To: <1403647225.29061.64.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2014 05:00 PM, Joe Perches wrote:
> On Tue, 2014-06-24 at 16:19 -0500, Tom Lendacky wrote:
>> Checkpatch issued a warning preferring to use kstrto<type> when
>> using a single variable sscanf.  Change the sscanf invocation to
>> a kstrtouint call.
> []
>> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
> []
>> @@ -165,10 +165,9 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
>>   		return len;
>>
>>   	workarea[len] = '\0';
>> -	if (sscanf(workarea, "%x", &scan_value) == 1)
>> -		*value = scan_value;
>> -	else
>> -		return -EIO;
>> +	ret = kstrtouint(workarea, 0, value);
>
> Don't you need to use 16 for the base here?

Using 0 allows for greater flexibility in the input format.

>
>> +	if (ret)
>> +		return ret;
>
> Are there any issues with any of the various callers
> getting a different error return?
>
> -EINVAL/-ERANGE vs -EIO ?
>

There shouldn't be, but I can always return -EIO to be
consistent with how it was previously.

Tom
>
