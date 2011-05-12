From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCHv3 net-next-2.6] ethtool: Added support for FW dump
Date: Thu, 12 May 2011 11:53:25 -0700
Message-ID: <39C0541A-9310-442C-8E47-99A3C12C65B2@qlogic.com>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1305154448-9687-2-git-send-email-anirban.chakraborty@qlogic.com>
 <1305219899.5214.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:34968 "EHLO
	TX2EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab1ELSxf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 14:53:35 -0400
In-Reply-To: <1305219899.5214.26.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 12, 2011, at 10:04 AM, Ben Hutchings wrote:

> On Wed, 2011-05-11 at 15:54 -0700, Anirban Chakraborty wrote:
>> <snip>
>> +/**
>> + * struct ethtool_dump - used for retrieving, setting device dump
>> + * @cmd: Command number - %ETHTOOL_GET_DUMP_FLAG, %ETHTOOL_GET_DUMP_DATA, or
>> + * 	%ETHTOOL_SET_DUMP
>> + * @version: FW version of the dump, filled in by driver
>> + * @flag: driver dependent flag for dump setting, filled in by driver during
>> + * 	  get and filled in by ethtool for set operation
>> + * @len: length of dump data, returned by driver for get operation
> 
> This is also used as the length of the user buffer on entry to
> ETHTOOL_GET_DUMP_DATA.
Will add that.

> 
>> + * @data: data collected for get dump data operation
>> + */
>> +struct ethtool_dump {
>> +	__u32	cmd;
>> +	__u32	version;
>> +	__u32	flag;
>> +	__u32	len;
>> +	u8	data[0];
>> +};
>> +
>> /* for returning and changing feature sets */
>> 
>> /**
>> @@ -853,6 +871,9 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
>>  * @get_channels: Get number of channels.
>>  * @set_channels: Set number of channels.  Returns a negative error code or
>>  *	zero.
>> + * @get_dump_flag: Get dump flag indicating current dump settings of the device.
> 
> This operation must also provide the dump length.
Thats correct. WIll add that bit of info.

> 
>> <snip>
>> +	memset(&tmp, 0, sizeof(tmp));
>> +	tmp.cmd = dump.cmd;
> 
> tmp.cmd should be ETHTOOL_GET_DUMP_FLAG.
Agreed.

> 
>> +	ret = ops->get_dump_flag(dev, &tmp);
>> +	if (ret)
>> +		return ret;
>> +
>> +	len = (tmp.len > dump.len) ? dump.len : tmp.len;
>> +
>> +	data = vzalloc(len);
>> +	if (!data)
>> +		return -ENOMEM;
> [...]
> 
> The kernel buffer size must be tmp.len, otherwise the driver may overrun
> the buffer.
Agreed.

Thanks,
Anirban


