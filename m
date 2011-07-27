From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] bonding: reduce noise during init
Date: Tue, 26 Jul 2011 17:37:19 -0700
Message-ID: <11239.1311727039@death>
References: <1311716107-12328-1-git-send-email-andy@greyhouse.net> <1311717286.15386.34.camel@Joe-Laptop>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:52522 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008Ab1G0AhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 20:37:24 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6R0V9kE004919
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 18:31:09 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6R0bN8V175008
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 18:37:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6QIbMQo004962
	for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 12:37:22 -0600
In-reply-to: <1311717286.15386.34.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

>On Tue, 2011-07-26 at 17:35 -0400, Andy Gospodarek wrote:
>> Many are using sysfs to configure bonding rather than module options, so
>> there is no need for bonding to throw this warning in normal cases.
>> Keep the message around when debugging is enabled as it might be useful
>> for someone desperate enough to enable debugging, but eliminate it
>> otherwise.
>[]
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>[]
>> @@ -4745,7 +4745,10 @@ static int bond_check_params(struct bond_params *params)
>>  		/* miimon and arp_interval not set, we need one so things
>>  		 * work as expected, see bonding.txt for details
>>  		 */
>> -		pr_warning("Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.\n");
>> +		pr_debug("Warning: either miimon or arp_interval and"
>> +			 " arp_ip_target module parameters must be specified,"
>> +			 " otherwise bonding will not detect link failures!"
>> +			 "  See bonding.txt for details.\n");
>
>I'd prefer you don't separate the format string
>into multiple pieces.

	Why not?  To me, it looks easier to read split into sections
that don't wrap lines.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
