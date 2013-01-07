From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] ethtool: consolidate work with ethtool_ops
Date: Mon, 7 Jan 2013 19:11:17 +0100
Message-ID: <20130107181117.GE1587@minipsycho.orion>
References: <1357561574-14255-1-git-send-email-jiri@resnulli.us>
 <1357575542.2658.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	richardcochran@gmail.com, greearb@candelatech.com,
	jeffrey.t.kirsher@intel.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:55343 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754322Ab3AGSLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 13:11:22 -0500
Received: by mail-ea0-f178.google.com with SMTP id k11so8057661eaa.23
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 10:11:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1357575542.2658.1.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 07, 2013 at 05:19:02PM CET, bhutchings@solarflare.com wrote:
>On Mon, 2013-01-07 at 13:26 +0100, Jiri Pirko wrote:
>> No need to check if ethtool_ops == NULL since it can't be.
>> Use local variable "ops" in functions where it is present
>> instead of dev->ethtool_ops
>> Introduce local variable "ops" in functions where dev->ethtool_ops is used
>> many times.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  net/core/ethtool.c | 45 +++++++++++++++++++++------------------------
>>  1 file changed, 21 insertions(+), 24 deletions(-)
>> 
>> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
>> index a870543..08c213e 100644
>> --- a/net/core/ethtool.c
>> +++ b/net/core/ethtool.c
>[...]
>> @@ -1082,9 +1083,10 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
>>  {
>>  	struct ethtool_value id;
>>  	static bool busy;
>> +	const struct ethtool_ops *ops = dev->ethtool_ops;
>>  	int rc;
>>  
>> -	if (!dev->ethtool_ops->set_phys_id)
>> +	if (ops->set_phys_id)
>>  		return -EOPNOTSUPP;
>[...]
>
>This condition is inverted.

Thanks, will fix this in v2

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
