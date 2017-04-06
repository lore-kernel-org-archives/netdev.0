From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next] bonding: attempt to better support longer hw
 addresses
Date: Thu, 6 Apr 2017 14:01:06 -0400
Message-ID: <fd21e0a4-0bd9-f07f-7204-2a95845dae38@redhat.com>
References: <20170404213242.50079-1-jarod@redhat.com>
 <20170405.184554.1608171595937690317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170405.184554.1608171595937690317.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-04-05 9:45 PM, David Miller wrote:
> From: Jarod Wilson <jarod@redhat.com>
> Date: Tue,  4 Apr 2017 17:32:42 -0400
...
> Applied, but:
> 
>> +static inline void bond_hw_addr_copy(u8 *dst, const u8 *src, unsigned int len)
>> +{
>> +	if (len == ETH_ALEN) {
>> +		ether_addr_copy(dst, src);
>> +		return;
>> +	}
>> +
>> +	memcpy(dst, src, len);
>> +}
> 
> I wonder how much value there is in trying to conditionally use
> ether_addr_copy().  Unless some of these calls are in the data
> plane, just a straight memcpy() all the time is fine and much
> simpler.

Yeah, I wasn't sure how much gain the bonding driver actually got from 
using the super-optimized ether_addr_copy(), and thought about just 
doing a memcpy all the time, but wanted to go for minimal impact to 
traditional ethernet bonding. Looks like bond_handle_frame() might 
benefit from sticking to ether_addr_copy() when it can, but the majority 
of other callers, at least in bond_main.c, are all in setup, teardown 
and failover paths, which ought to be tolerant of some overhead, though 
optimized failover isn't a bad thing for connection uptime. I do see 
bond_alb.c has one caller in the arp transmit path as well. I think I'm 
inclined to just leave well enough alone for the moment.

-- 
Jarod Wilson
jarod@redhat.com
