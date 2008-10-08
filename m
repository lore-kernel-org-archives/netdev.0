From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 15:05:44 -0400
Message-ID: <48ED0488.7080502@hp.com>
References: <48EC091D.7080207@hp.com> <48ECF8AA.2020205@hp.com> <17192.1223490884@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:24914 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbYJHTFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:05:47 -0400
In-Reply-To: <17192.1223490884@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
> 
>>> +
>>> +	list_for_each_entry(bond, &bond_dev_list, bond_list) {
>>> +		if (bond->dev == event_dev) {
>>> +			switch (event) {
>>> +			case NETDEV_UP:
>>> +				ipv6_addr_copy(&bond->master_ipv6, &ifa->addr);
>>> +				return NOTIFY_OK;
>> I think you want to store the first address configured on the device (most
>> likely link-local), and not overwrite it every time  a new address is
>> configured.  Since new addresses can be configured rather often (think
>> temporary, new RAs, etc) we really want the most stable address we can have.
>> Also, since ND is a link protocol, link-local is sufficient.
> 
> 	That depends upon how the IPv6 unsolicited NAs are handled by
> the switch.  For IPv4, we issue a gratuitous ARP for one of the IP
> addresses on the interface to update the switch's MAC table; for this
> case, it doesn't matter which IP address is used.
> 
> 	If IPv6-smart switches snoop the same way, then it again doesn't
> matter which IPv6 address is used; this is just to update the MAC table.
> I'll agree that it's logically sensible to use a link-local, though.
> If, on the other hand, IPv6 needs an update for each configured address,
> then storing just one IPv6 address is insufficient (as we'd need an NA
> for each address).

My testing has shown that it doesn't matter which address I send the NA 
for, I can ping both the link-local and global without dropping a packet 
simultaneously.  I'm using a Procurve 5400 series switch for what it's 
worth that has IPv6 support, not sure if something not as recent would 
behave any different.

-Brian
