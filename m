From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on failover
Date: Mon, 27 Oct 2008 17:24:00 -0700
Message-ID: <2171.1225153440@death.nxdomain.ibm.com>
References: <48EEA752.6030505@hp.com> <49061F87.2090409@hp.com>
Cc: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Simon Horman <horms@verge.net.au>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:33837 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751792AbYJ1AYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 20:24:03 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9S0NPMR015008
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 18:23:25 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9S0O24D104356
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 18:24:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9S0NXft008223
	for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 18:23:33 -0600
In-reply-to: <49061F87.2090409@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:

>Hi Jay,
>
>Did you ever get a chance to look at this patch?  Now that net-next is
>open I'd like to resubmit it.

	I'm good with it; I'm merging it with a couple of other feature
things and I'll post it with that set in a day or two when things open
(unless I missed a mail, I don't think net-next is open as I type this).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


>Thanks,
>
>-Brian
>
>Brian Haley wrote:
>> Updated to address Vlad's comment about storing the link-local IPv6
>> address in the bond/vlan structure, I no longer overwrite the existing
>> address with a newer one.  Also added missed locking for the inet6_dev.
>>
>> I don't see any way to address David Steven's comment since there is
>> currently no NA tunable in the IPv6 code.
>>
>> ---
>>
>> This patch adds better IPv6 failover support for bonding devices,
>> especially when in active-backup mode and there are only IPv6 addresses
>> configured, as reported by Alex Sidorenko.
>>
>> - Creates a new file, net/drivers/bonding/bond_ipv6.c, for the
>>   IPv6-specific routines.  Both regular bonds and VLANs over bonds
>>   are supported.
>>
>> - Adds a new tunable, num_unsol_na, to limit the number of unsolicited
>>   IPv6 Neighbor Advertisements that are sent on a failover event.
>>   Default is 1.
>>
>> - Creates two new IPv6 neighbor discovery functions:
>>
>>   ndisc_build_skb()
>>   ndisc_send_skb()
>>
>>   These were required to support VLANs since we have to be able to
>>   add the VLAN id to the skb since ndisc_send_na() and friends
>>   shouldn't be asked to do this.  These two routines are basically
>>   __ndisc_send() split into two pieces, in a slightly different order.
>>
>> - Updates Documentation/networking/bonding.txt and bumps the rev of bond
>>   support to 3.4.0.
>>
>> On failover, this new code will generate one packet:
>>
>> - An unsolicited IPv6 Neighbor Advertisement, which helps the switch
>>   learn that the address has moved to the new slave.
>>
>> Testing has shown that sending just the NA results in pretty good
>> behavior when in active-back mode, I saw no lost ping packets for example.
>>
>> -Brian
>>
>> Signed-off-by: Brian Haley <brian.haley@hp.com>
>> ---
>>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
