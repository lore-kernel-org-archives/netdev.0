From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing
 probe
Date: Sat, 14 Jan 2012 07:54:27 -0800
Message-ID: <4F11A533.4040406@linux.intel.com>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com> <20120114.001430.787918662083526597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	alan@linux.intel.com, tomoya.rohm@gmail.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32885 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755164Ab2ANP4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jan 2012 10:56:06 -0500
In-Reply-To: <20120114.001430.787918662083526597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/14/2012 12:14 AM, David Miller wrote:
> From: Darren Hart <dvhart@linux.intel.com>
> Date: Fri, 13 Jan 2012 22:44:55 -0800
> 
>> If the MAC is invalid or not implemented, use a randomly generated one rather
>> than failing the probe. Store the generated addr in a new sw_mac array in the
>> pch_gbe_mac_info structure. Take care to allow for assigning the MAC via
>> ifconfig by reusing sw_addr to store an assigned mac if probe populated it with
>> a random one (otherwise the assignment would rely on the ROM and the reset would
>> fail to write a valid MAC to the rx filter).
>>
>> Tested on two platforms, one with a valid MAC, the other without a MAC. The
>> real MAC is used if present, a randomly generated one otherwise. Both are
>> capable of changing the MAC with ifconfig. They successfully get an IP over
>> DHCP and pass a simple ping and login over ssh test.
>>
>> This does not make any attempt to address a missing or invalid MAC for the
>> pch_phub driver.
>>
>> Signed-off-by: Darren Hart <dvhart@linux.intel.com>
> 
> I don't want to see code like this added if it's "just in case."

I don't disagree, unfortunately it is not "just in case". The Inforce
Goldstein QSeven Module on the Portwell PQ7-C100XL carrier board are
already available and do not implement the MAC EEPROM in hardware.

> 
> Please correct any hardware that hasn't shipped yet or is alpha/beta
> hardware in testing, so that we don't need stuff like this.

I saw that the use of random_ether_addr is fairly prevalent, and
attempted a roughly similar sort of approach to others I had seen. Do
you consider all of those to be "necessary evils" or are there
legitimate situations for its use?

In any case, with existing hardware out there that is unusable with the
current pch_gbe driver, can we consider this workaround for inclusion?

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
