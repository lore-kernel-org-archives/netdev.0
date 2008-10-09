From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 22:08:42 -0400
Message-ID: <48ED67AA.9020002@hp.com>
References: <OF3F6EE419.BE384A50-ON882574DC.0063AD5A-882574DC.0064A148@us.ibm.com>	 <48ED03A6.2060705@hp.com> <1223504558.22343.15.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>, fubar@linux.vnet.ibm.com,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Vladislav Yasevich <vladislav.yasevich@hp.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:1183 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbYJICIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 22:08:48 -0400
In-Reply-To: <1223504558.22343.15.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala wrote:
> On Wed, 2008-10-08 at 15:01 -0400, Brian Haley wrote:
>> David Stevens wrote:
>>> Well, actually, it looks like I'm suggesting you to re-use something that 
>>> doesn't
>>> exist. :-)
>>>
>>> MLD (and IGMP) has such a thing where unsolicited advertisements are sent
>>> multiple times, with delays in between, to account for lossy networks 
>>> possibly
>>> dropping the first one. There are configurable counts associated with 
>>> probes
>>> and retransmit intervals for solicits, but I don't see the equivalent yet 
>>> for
>>> unsolicited NA's.
>> I don't see an equivalent either, since the only unsolicited NA the 
>> kernel sends is for DAD, which uses dad_transmits.
> 
> Doesn't DAD use neighbor solicitation rather than unsolicited NA?

Yes.  There is one case in the NS code that will respond with an 
unsolicited NA if we get a NS doing DAD.  I guess I should have made it 
clearer that it's when we're defending our address during a DAD probe.

> Can we use NS in the bonding failover scenario too?

Both and NS and NA seemed to update the switch, so either one can be 
sent on a failover event.  It seemed to be the consensus that the NA was 
more appropriate, especially since we can send it without the solicited 
bit set.

-Brian
