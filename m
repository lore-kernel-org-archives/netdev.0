From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] amd-xgbe: Resolve checkpatch warning
 about sscanf usage
Date: Thu, 26 Jun 2014 17:12:55 -0700 (PDT)
Message-ID: <20140626.171255.274497260661771827.davem@davemloft.net>
References: <1403647225.29061.64.camel@joe-AO725>
	<53A9FF42.2090502@amd.com>
	<1403650410.11163.2.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaF0AM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 20:12:56 -0400
In-Reply-To: <1403650410.11163.2.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 24 Jun 2014 15:53:30 -0700

> On Tue, 2014-06-24 at 17:44 -0500, Tom Lendacky wrote:
>> On 06/24/2014 05:00 PM, Joe Perches wrote:
>> > On Tue, 2014-06-24 at 16:19 -0500, Tom Lendacky wrote:
>> >> Checkpatch issued a warning preferring to use kstrto<type> when
>> >> using a single variable sscanf.  Change the sscanf invocation to
>> >> a kstrtouint call.
>> > []
>> >> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
>> > []
>> >> @@ -165,10 +165,9 @@ static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
>> >>   		return len;
>> >>
>> >>   	workarea[len] = '\0';
>> >> -	if (sscanf(workarea, "%x", &scan_value) == 1)
>> >> -		*value = scan_value;
>> >> -	else
>> >> -		return -EIO;
>> >> +	ret = kstrtouint(workarea, 0, value);
>> >
>> > Don't you need to use 16 for the base here?
> 
>> Using 0 allows for greater flexibility in the input format.
> 
> True, but there could be a change in behavior like reading a
> previously hex value like 10 is now a decimal 10 not decimal 16.

Tom, under other circumstance you can't change the format.
v3.16 is going to be released with the existing %x formatting
expecting hexadecimal numbers.

And you're targetting this change to decimal format in net-next.

The only thing that really allows you to do this is that this is
debugfs, and it's a reason I really hate debugfs, people do
arbitrary stuff so that if the debugfs elements turn out to be
useful for someone the driver author can arbitarily break things
on them however they want.

It's a cop-out for things people don't want to be bound to avoid ABI
changes, and to me that's garbage.  If you expose it to the user
design it well to the point where you're willing to live with it's
interface forever, or don't expose it to the user at all.
