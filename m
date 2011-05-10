From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCHv2 net-next-2.6] ethtool: Added support for FW dump
Date: Tue, 10 May 2011 13:22:55 -0700
Message-ID: <8EE73B82-F30A-41F7-B220-33362F0E45C4@qlogic.com>
References: <1304989352-24810-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1304989352-24810-2-git-send-email-anirban.chakraborty@qlogic.com>
 <1305052186.2859.47.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:31375 "EHLO
	TX2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161Ab1EJUW7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:22:59 -0400
In-Reply-To: <1305052186.2859.47.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 10, 2011, at 11:29 AM, Ben Hutchings wrote:

> On Mon, 2011-05-09 at 18:02 -0700, Anirban Chakraborty wrote:
>> Added code to take FW dump via ethtool. A pair of set and get functions are
>> added to configure dump level and fetch dump data from the driver respectively.
> 
> I don't understand why you are combining get-flags and get-data in the
> driver interface.  I suggested that you could use a single option for
> these in the ethtool *utility*, but combining them in the driver
> interface just seems to complicate the implementation of the ethtool
> core code and the driver.

I was under the impression that you wanted to collapse get data and flag into one operation,
both in ethtool and in the driver. Will change it in next version.

> 
>> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>> ---
>> include/linux/ethtool.h |   31 +++++++++++++++++++++++
>> net/core/ethtool.c      |   62 +++++++++++++++++++++++++++++++++++++++++++++++
>> 2 files changed, 93 insertions(+), 0 deletions(-)
>> 
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index bd0b50b..f2cd7e1 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -601,6 +601,31 @@ struct ethtool_flash {
>> 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
>> };
>> 
>> +/**
>> + * struct ethtool_dump - used for retrieving, setting device dump
> 
> Missing description of @cmd.
> 
>> + * @type: type of operation, get dump settings or data
>> + * @version: FW version of the dump
>> + * @flag: flag for dump setting
>> + * @len: length of dump data
>> + * @data: data collected for this command
> 
> The kernel-doc needs to describe when the fields are valid - i.e. which
> commands use them as input and/or output.

Will fix.

> <snip>
>> 
>> +
>> +	data = vzalloc(dump.len);
>> +	if (!data)
>> +		return -ENOMEM;
>> +	ret = ops->get_dump(dev, &dump, data);
>> +	if (ret) {
>> +		ret = -EFAULT;
> 
> There is no reason to change ret here.  Didn't I already raise this in
> version 1?

Yes you did. Although I fixed others, but some how I missed this one.
> 
>> +		goto out;
>> +	}
>> +	useraddr += offsetof(struct ethtool_dump, data);
>> +	if (copy_to_user(useraddr, data, dump.len))
> 
> The copied length should be the *minimum* of the user's buffer length
> and the actual dump length.
Will fix it.


