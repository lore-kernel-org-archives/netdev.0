From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 11:34:44 -0700
Message-ID: <17192.1223490884@death.nxdomain.ibm.com>
References: <48EC091D.7080207@hp.com> <48ECF8AA.2020205@hp.com>
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:56361 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754572AbYJHSet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 14:34:49 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m98IYmmd005391
	for <netdev@vger.kernel.org>; Wed, 8 Oct 2008 14:34:48 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m98IYmfu265118
	for <netdev@vger.kernel.org>; Wed, 8 Oct 2008 14:34:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m98IYmp7003829
	for <netdev@vger.kernel.org>; Wed, 8 Oct 2008 14:34:48 -0400
In-reply-to: <48ECF8AA.2020205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich@hp.com> wrote:

>> +
>> +	list_for_each_entry(bond, &bond_dev_list, bond_list) {
>> +		if (bond->dev == event_dev) {
>> +			switch (event) {
>> +			case NETDEV_UP:
>> +				ipv6_addr_copy(&bond->master_ipv6, &ifa->addr);
>> +				return NOTIFY_OK;
>
>I think you want to store the first address configured on the device (most
>likely link-local), and not overwrite it every time  a new address is
>configured.  Since new addresses can be configured rather often (think
>temporary, new RAs, etc) we really want the most stable address we can have.
>Also, since ND is a link protocol, link-local is sufficient.

	That depends upon how the IPv6 unsolicited NAs are handled by
the switch.  For IPv4, we issue a gratuitous ARP for one of the IP
addresses on the interface to update the switch's MAC table; for this
case, it doesn't matter which IP address is used.

	If IPv6-smart switches snoop the same way, then it again doesn't
matter which IPv6 address is used; this is just to update the MAC table.
I'll agree that it's logically sensible to use a link-local, though.
If, on the other hand, IPv6 needs an update for each configured address,
then storing just one IPv6 address is insufficient (as we'd need an NA
for each address).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
