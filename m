From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [ethtool PATCH 1/1] ethtool: Support cpsw ale-table registers
 in -d
Date: Wed, 24 Sep 2014 11:02:22 +0530
Message-ID: <54225766.5020407@ti.com>
References: <1406107764-1737-1-git-send-email-mugunthanvnm@ti.com> <1411340326.20019.32.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:55044 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783AbaIXFci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 01:32:38 -0400
In-Reply-To: <1411340326.20019.32.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 22 September 2014 04:28 AM, Ben Hutchings wrote:
> Sorry I didn't respond to this earlier.
> 
> On Wed, 2014-07-23 at 14:59 +0530, Mugunthan V N wrote:
> [...]
>> --- /dev/null
>> +++ b/cpsw.c
> [...]
>> +static inline void cpsw_ale_set_field(u32 *ale_entry, u32 start, u32 bits,
>> +				      u32 value)
>> +{
>> +	int idx;
>> +
>> +	value &= BITMASK(bits);
>> +	idx    = start / 32;
>> +	start -= idx * 32;
>> +	idx    = 2 - idx; /* flip */
>> +	ale_entry[idx] &= ~(BITMASK(bits) << start);
>> +	ale_entry[idx] |=  (value << start);
>> +}
>> +
>> +#define DEFINE_ALE_FIELD(name, start, bits)				\
>> +static inline int cpsw_ale_get_##name(u32 *ale_entry)			\
>> +{									\
>> +	return cpsw_ale_get_field(ale_entry, start, bits);		\
>> +}									\
>> +static inline void cpsw_ale_set_##name(u32 *ale_entry, u32 value)	\
>> +{									\
>> +	cpsw_ale_set_field(ale_entry, start, bits, value);		\
>> +}
> 
> The setter functions are unused.

Will fis this in next version

> 
> [...]
>> +int cpsw_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
>> +{
>> +	u32 *reg = (u8 *)regs->data;
>> +	u32 len = regs->len / 3;
>> +	int i;
>> +
>> +	fprintf(stdout, "cpsw hw version %d.%d (%d)\n",
>> +		CPSW_MAJOR_VERSION(regs->version),
>> +		CPSW_MINOR_VERSION(regs->version),
>> +		CPSW_RTL_VERSION(regs->version));
> [...]
> 
> There needs to be a version check here.  Some future version of the
> hardware or driver may introduce an incompatible dump format.
> 

Will check the hardware version in v2.

Regards
Mugunthan V N
