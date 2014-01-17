From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 0/6] bonding: only rely on arp packets if arp
 monitor is used
Date: Fri, 17 Jan 2014 09:02:41 +0100
Message-ID: <20140117080241.GB5699@redhat.com>
References: <1389837916-5377-1-git-send-email-vfalico@redhat.com>
 <15764.1389848997@death.nxdomain>
 <20140115.220132.1518410490710218099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56907 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215AbaAQIFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 03:05:39 -0500
Content-Disposition: inline
In-Reply-To: <20140115.220132.1518410490710218099.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 10:01:32PM -0800, David Miller wrote:
>From: Jay Vosburgh <fubar@us.ibm.com>
>Date: Wed, 15 Jan 2014 21:09:57 -0800
>
>> 	The main reason for preserving the non-validate behavior (any
>> traffic counts) is for the loadbalance (xor and rr) modes.  In those
>> modes, the switch decides which slave receives the incoming traffic, and
>> so it's to our advantage to permit any incoming traffic to count for
>> "up-ness."  The arp_validate option is not allowed in these modes
>> because it won't work.
>>
>> 	With these changes, I suspect that the loadbalance ARP monitor
>> will be less reliable with these changes (granted that it's already a
>> bit dodgy in its dependence on the switch to hit all slaves with
>> incoming packets regularly).  Particularly if the switch ports are
>> configured into an Etherchannel ("static link aggregation") group, in
>> which case only one slave will receive any given frame (broadcast /
>> multicast traffic will not be duplicated across all slaves).
>>
>> 	I'm not sure that this change (the "only count ARPs even without
>> arp_validate" bit) won't break existing configurations.  Did you test
>> the -rr and -xor modes with ARP monitor after your changes (with and
>> without configuring a channel group on the switch ports)?
>
>Sorry Jay, I only read this just now.  I won't push these changes
>out until you've had some time to discuss them.

Sorry David, this change indeed might break some configurations (leaving
aside the question if they're legit or not...). So, please, drop them, I'll
discuss with Jay and send a v2.

Thanks a lot, and sorry for the noise.

>
>To my untrained eye they looked rather straightforward :-)
