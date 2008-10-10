From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH v2] bonding: send IPv6 neighbor advertisement on	failover
Date: Fri, 10 Oct 2008 13:15:08 -0400
Message-ID: <48EF8D9C.2040605@hp.com>
References: <OFB8A232B8.61496942-ON882574DE.0051B425-882574DE.0052AFD3@us.ibm.com>	 <29444.1223654036@death.nxdomain.ibm.com> <48EF7CFF.4050405@hp.com>	 <48EF82D2.6030008@hp.com> <1223657772.10489.5.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, Jay Vosburgh <fubar@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:37749 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759938AbYJJRPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 13:15:12 -0400
In-Reply-To: <1223657772.10489.5.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sridhar Samudrala wrote:
> On Fri, 2008-10-10 at 12:29 -0400, Vlad Yasevich wrote:
>> Brian Haley wrote:
>>> Jay Vosburgh wrote:
>>>>     As a semi-related question, what does IPv6 do if it receives a
>>>> gratutitous NA, and finds a duplicate?
> 
> I think Jay was asking about the case where the target address in the NA 
> matches the address of the receiving interface. The RFCs don't describe
> how to handle such a case and leave it to the implementation. Linux logs
> a warning message and ignores such NA.
> 

Yes, but in this case, you have duplicate addresses configured.  This
can happen when subnets merge and isn't really related to bonding driver.

In such a case, if we do an NS, it will trigger an NA and we'll end up
logging such a warning.  If we do an NA, the other end, if it's linux, will
log this warning, or deal with it in its own manner.

So, it's really a draw.

-vlad

> Thanks
> Sridhar
> 
>>> If a node has an IPv6 neighbor entry and receives an unsolicited NA it
>>> will change it's state to stale, forcing a re-lookup on the next
>>> transmit.  An un-solicited NA will change the state to reachable.
>>                 ^^^^^^^^^^^^
>>
>> You probably meant to say "solicited".  Unsolicited NAs can only change
>> the state to STALE.
>>
>> Also, the re-lookup will happen on a delay after the transmit.
>>
>> -vlad
> 
> 

