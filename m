From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V1 5/9] net/eipoib: Add ethtool file support
Date: Thu, 19 Jul 2012 18:55:57 +0300
Message-ID: <50082E0D.9070202@mellanox.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>  <1342609202-32427-6-git-send-email-ogerlitz@mellanox.com> <1342636621.2617.63.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<netdev@vger.kernel.org>, <ali@mellanox.com>,
	<sean.hefty@intel.com>, <shlomop@mellanox.com>,
	Erez Shitrit <erezsh@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:37759 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750852Ab2GSP4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:56:08 -0400
In-Reply-To: <1342636621.2617.63.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/18/2012 9:37 PM, Ben Hutchings wrote:
> +static void parent_get_strings(struct net_device *parent_dev,
> +			       uint32_t stringset, uint8_t *data)
> +{
> +	int index = 0, stats_off = 0, i;
> +
> +	if (stringset != ETH_SS_STATS)
> +		return;
> +
> +	for (i = 0; i < PORT_STATS_LEN; i++)
> +		strcpy(data + (index++) * ETH_GSTRING_LEN,
> +		       parent_strings[i + stats_off]);
> +
> +	stats_off += PORT_STATS_LEN;
> This is a very longwinded way to write:
> 	memcpy(data, parent_strings, sizeof(parent_strings));

SURE, will fix

>
>> +static int parent_get_sset_count(struct net_device *parent_dev, int sset)
>> +{
>> +	switch (sset) {
>> +	case ETH_SS_STATS:
>> +		return PARENT_STATS_LEN;
>>
> [...]
>
> I get the feeling you've removed some code with unifdef; the result
> looks really weird, with PORT_STATS_LEN and PARENT_STATS_LEN used
> inconsistently.

yep, this needs cleanup, will do for V2

Or.
