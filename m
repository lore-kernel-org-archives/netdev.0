From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on failover
Date: Fri, 10 Oct 2008 08:53:56 -0700
Message-ID: <29444.1223654036@death.nxdomain.ibm.com>
References: <OFB8A232B8.61496942-ON882574DE.0051B425-882574DE.0052AFD3@us.ibm.com>
Cc: Brian Haley <brian.haley@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:54771 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757858AbYJJPy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 11:54:28 -0400
In-reply-to: <OFB8A232B8.61496942-ON882574DE.0051B425-882574DE.0052AFD3@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens <dlstevens@us.ibm.com> wrote:

>Brian Haley <brian.haley@hp.com> wrote on 10/10/2008 07:34:58 AM:
>
>> I don't really want to since this is bonding-specific behavior, and 
>> we're not performing DAD for the address.  This is just another sysfs 
>> entry: /sys/class/net/bond*/bonding/num_unsol_na, not a sysctl.
>
>        I think they really are the same case, and doing DAD
>would solve the problem just as well. But I can hold my nose a
>little bit and live with it. :-) Getting the problem solved is
>more important than the details.

	If I'm reading things correctly, DAD sends neighbor
solicitations, and we're sending neighbor advertisements, and not
running the DAD logic.

	As a semi-related question, what does IPv6 do if it receives a
gratutitous NA, and finds a duplicate?

	I agree that doing DAD would update the switches, peers, etc,
but, if I'm reading the IPv6 code correctly, the delay between probes is
one second (nd_tbl.retrans_time), and it looks like there's an initial
delay of up to 1 second as well (in addrconf_dad_kick, the
rtr_solicit_delay).  For failover purposes, we want to issue the
gratuitous ARP or NA packets immediately with a minimal delay between
probes.

	Is my understanding of the DAD behavior correct?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
