From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [ethtool PATCH] FW dump support
Date: Wed, 4 May 2011 11:02:52 -0700
Message-ID: <5DC58DA2-78B0-467C-BC72-D4346C5BA59C@qlogic.com>
References: <1304378957-24123-1-git-send-email-anirban.chakraborty@qlogic.com>
 <1304530807.2926.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.186]:35553
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755116Ab1EDSEF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 14:04:05 -0400
In-Reply-To: <1304530807.2926.28.camel@bwh-desktop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 4, 2011, at 10:40 AM, Ben Hutchings wrote:

> On Mon, 2011-05-02 at 16:29 -0700, anirban.chakraborty@qlogic.com wrote:
>> From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>> 
>> Added support to take FW dump via ethtool.
> [...]
>> --- a/ethtool.c
>> +++ b/ethtool.c
> [...]
>> @@ -263,6 +270,12 @@ static struct option {
>> 		"Get Rx ntuple filters and actions\n" },
>>     { "-P", "--show-permaddr", MODE_PERMADDR,
>> 		"Show permanent hardware address" },
>> +    { "-W", "--get-dump", MODE_GET_DUMP,
>> +		"Get dump level\n" },
>> +    { "-Wd", "--get-dump-data", MODE_GET_DUMP_DATA,
>> +		"Get dump data", "FILENAME " "Name of the dump file\n" },
> 
> The short options should only include one letter.  Also the general
> pattern is that 'get' options use lower-case letters and 'set' options
> use upper-case letters.  No, I'm not sure how best to handle a set of 3
> options.  Maybe you can combine --get-dump and --get-dump-data, making
> the filename optional?

Thanks for the info, I was not aware of it. Will address it.

> 
>> +    { "-w", "--set-dump", MODE_SET_DUMP,
>> +		"Set dump level", "DUMPLEVEL " "Dump level for the device\n" },
> 
> The field this sets is described as 'flags' so does it consist of flags
> or is it a level?
The idea is to have an opaque flag for the driver that it uses to set the dump level
(and hence the size) of it. I will use flag instead of level here so that there is no
ambiguity.

> 
> [...]
>> @@ -3241,6 +3270,86 @@ static int do_grxntuple(int fd, struct ifreq *ifr)
>> 	return 0;
>> }
>> 
>> +static void do_writedump(struct ethtool_dump *dump)
>> +{
>> +	FILE *f = fopen(dump_file, "wb+");
>> +	size_t bytes;
>> +
>> +	if (!f ) {
>> +		fprintf(stderr, "Can't open file %s: %s\n",
>> +			dump_file, strerror(errno));
>> +		return;
> 
> On error, we must exit with code 1.
Will do.

> 
>> +	}
>> +
>> +	bytes = fwrite(dump->data, 1, dump->len, f);
>> +	fclose(f);
> [...]
> 
> These functions can also fail and need to be checked.  (Yes, fclose()
> can fail, since it may have to flush buffered data.)

I agree. Will fix it. Thanks for the feedback.

-Anirban


