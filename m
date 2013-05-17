From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Update vxlan fdb 'used' field after each usage.
Date: Fri, 17 May 2013 01:31:38 -0700 (PDT)
Message-ID: <20130517.013138.817623345565928032.davem@davemloft.net>
References: <1368723943.14093.4.camel@sridhar.usor.ibm.com>
	<20130516.150019.1779890463663876284.davem@davemloft.net>
	<1368742964.14093.19.camel@sridhar.usor.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875Ab3EQIbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 04:31:38 -0400
In-Reply-To: <1368742964.14093.19.camel@sridhar.usor.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 16 May 2013 15:22:44 -0700

> On Thu, 2013-05-16 at 15:00 -0700, David Miller wrote:
>> From: Sridhar Samudrala <sri@us.ibm.com>
>> Date: Thu, 16 May 2013 10:05:43 -0700
>> 
>> > Fix some instances where vxlan fdb 'used' field is not updated after the entry 
>> > is used.
>> > 
>> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
>> 
>> Please just put the ->used update into vxlan_find_mac().
> 
> I thought of doing it that way, but i found that there is a call
> to vxlan_find_mac() in vxlan_fdb_create() where the fdb entry
> gets updated, but it not really used.
> 
> Also in other cases, the fdb entry may not be used even if
> vxlan_find_mac() returns an entry because of other conditions.
> 
> I guess it depends on how we define the 'used' field.

Make a new __vxlan_find_mac() or similar that doesn't update
->used, and invoke it from vxlan_fdb_create().
