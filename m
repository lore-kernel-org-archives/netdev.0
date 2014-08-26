From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next v3 2/3] ethtool: Add generic options for
 tunables
Date: Wed, 27 Aug 2014 03:03:23 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1408270247280.28873@ws.cisco>
References: <1408008560-1067-1-git-send-email-_govind@gmx.com>  <1408008560-1067-3-git-send-email-_govind@gmx.com> <1408749965.4672.29.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, stephen@networkplumber.org,
	ssujith@cisco.com, benve@cisco.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:54823 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754175AbaHZVdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2014 17:33:49 -0400
In-Reply-To: <1408749965.4672.29.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Aug 2014, Ben Hutchings wrote:
> On Thu, 2014-08-14 at 14:59 +0530, Govindarajulu Varadarajan wrote:
>> @@ -257,6 +262,7 @@ struct ethtool_ops {
>>  				     struct ethtool_eeprom *, u8 *);
>>  	int	(*get_eee)(struct net_device *, struct ethtool_eee *);
>>  	int	(*set_eee)(struct net_device *, struct ethtool_eee *);
>> +	struct ethtool_tunable_ops tunable_ops[ETHTOOL_TUNABLE_MAX];
>
> This is OK but if we add a lot of tunables then it bloats up each driver
> with a (probably quite sparse) array of function pointers.
>

Will fix with David's suggestion.

>> +struct ethtool_tunable {
>> +	u32 cmd;
>> +	u32 tcmd;
>> +	u32 len;
>> +	union {
>> +		u32 rx_copybreak;
>> +		u32 data[48];
>> +	} data;
> [...]
>
> This is not at all generic.  If tunables don't all have the same type,
> then the type - not just the length - should be explicit.
>
> I also think that if the length of a value can vary then we should not
> declare a data member at all.  So we would have something like:
>
> struct ethtool_tunable {
> 	__u32	cmd;
> 	__u32	id;
> 	__u32	type_id;
> 	__u32	len;
> 	__u8	data[0];
> };
>
> Then the value buffer would be passed to the driver functions separately
> (as for other variable-length command structures).
>

OK. id show be the tunable command type right? Like RX_COPYBREAK, TX_COPYBREAK
etc. What is the type_id?

> By the way, you must use double-underscore prefixes on fixed-width
> integer type names in UAPI headers.
>

will fix it.

Thanks
