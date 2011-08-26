From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] e1000: save skb counts in TX to avoid
 cache misses
Date: Fri, 26 Aug 2011 12:55:29 -0400 (EDT)
Message-ID: <20110826.125529.1284864994760116940.davem@davemloft.net>
References: <20110826003923.4083.24862.email-sent-by-dnelson@localhost6.localdomain6>
	<1314330760.2097.39.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dnelson@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab1HZQzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:55:35 -0400
In-Reply-To: <1314330760.2097.39.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 25 Aug 2011 20:52:39 -0700

> On Thu, 2011-08-25 at 17:39 -0700, Dean Nelson wrote:
>> Virtual Machines with emulated e1000 network adapter running on
>> Parallels'
>> server were seeing kernel panics due to the e1000 driver dereferencing
>> an
>> unexpected NULL pointer retrieved from buffer_info->skb.
>> 
>> The problem has been addressed for the e1000e driver, but not for the
>> e1000.
>> Since the two drivers share similar code in the affected area, a port
>> of the
>> following e1000e driver commit solves the issue for the e1000 driver:
>> 
>> commit 9ed318d546a29d7a591dbe648fd1a2efe3be1180
>> Author: Tom Herbert <therbert@google.com>
>> Date:   Wed May 5 14:02:27 2010 +0000
>> 
>>     e1000e: save skb counts in TX to avoid cache misses
>> 
>>     In e1000_tx_map, precompute number of segements and bytecounts
>> which
>>     are derived from fields in skb; these are stored in buffer_info.
>> When
>>     cleaning tx in e1000_clean_tx_irq use the values in the associated
>>     buffer_info for statistics counting, this eliminates cache misses
>>     on skb fields.
>> 
>> 
>> Signed-off-by: Dean Nelson <dnelson@redhat.com> 
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
