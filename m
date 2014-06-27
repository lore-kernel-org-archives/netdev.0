From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next 6/6] amd-xgbe: Resolve checkpatch warning about
 sscanf usage
Date: Fri, 27 Jun 2014 08:35:49 -0500
Message-ID: <53AD7335.7060800@amd.com>
References: <1403647225.29061.64.camel@joe-AO725>	<53A9FF42.2090502@amd.com>
	<1403650410.11163.2.camel@joe-AO725>
 <20140626.171255.274497260661771827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0204.outbound.protection.outlook.com ([207.46.163.204]:3161
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752822AbaF0NgM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2014 09:36:12 -0400
In-Reply-To: <20140626.171255.274497260661771827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26/2014 07:12 PM, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 24 Jun 2014 15:53:30 -0700
>
>> On Tue, 2014-06-24 at 17:44 -0500, Tom Lendacky wrote:
>>> On 06/24/2014 05:00 PM, Joe Perches wrote:
>>>> On Tue, 2014-06-24 at 16:19 -0500, Tom Lendacky wrote:
>>>>> Checkpatch issued a warning preferring to use kstrto<type> when
>>>>> using a single variable sscanf.  Change the sscanf invocation to
>>>>> a kstrtouint call.
>>>> []
>>>>> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
>>>> []
>>>>> @@ -165,10 +165,9 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
>>>>>    		return len;
>>>>>
>>>>>    	workarea[len] = '\0';
>>>>> -	if (sscanf(workarea, "%x", &scan_value) == 1)
>>>>> -		*value = scan_value;
>>>>> -	else
>>>>> -		return -EIO;
>>>>> +	ret = kstrtouint(workarea, 0, value);
>>>>
>>>> Don't you need to use 16 for the base here?
>>
>>> Using 0 allows for greater flexibility in the input format.
>>
>> True, but there could be a change in behavior like reading a
>> previously hex value like 10 is now a decimal 10 not decimal 16.
>
> Tom, under other circumstance you can't change the format.
> v3.16 is going to be released with the existing %x formatting
> expecting hexadecimal numbers.
>
> And you're targetting this change to decimal format in net-next.
>
> The only thing that really allows you to do this is that this is
> debugfs, and it's a reason I really hate debugfs, people do
> arbitrary stuff so that if the debugfs elements turn out to be
> useful for someone the driver author can arbitarily break things
> on them however they want.
>
> It's a cop-out for things people don't want to be bound to avoid ABI
> changes, and to me that's garbage.  If you expose it to the user
> design it well to the point where you're willing to live with it's
> interface forever, or don't expose it to the user at all.
>

After Joe's comments I started looking around to see what is expected
of debugfs.  I had always been under the impression that you shouldn't
expect things to remain compatible under debugfs.  But after reading a
number of things it appears that tools get created based on your
interface and then break when it's changed.

I'll submit a follow-on patch that addresses Joe's and your concerns and
put the interface back to just hexadecimal input with -EIO return on
error to maintain compatibility with what is in 3.16

Thanks,
Tom
