From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 15:07:51 -0400
Message-ID: <48ED0507.30002@hp.com>
References: <48EC091D.7080207@hp.com> <48ECF8AA.2020205@hp.com> <17192.1223490884@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:36535 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbYJHTHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:07:54 -0400
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
> 

Yes, but the unsolicited NA for the global address just looks rather strange
when the link local one is provide.  Also, with temporaries that can come and
go, it's better to use a stable address.

We are simply using it to refresh the MAC tables and for a while I thought it
would be sufficient to do just one ARP or ND, but then I realized that in an
environment where 2 systems are connected back-to-back, you would potentially
need to do both.  Need to play with this config...

-vlad

> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 

