From: Bob Gilligan <gilligan@vyatta.com>
Subject: Re: the maximal speed of pktgen with 1Gbps NIC
Date: Wed, 22 Jul 2009 10:12:17 -0700
Message-ID: <4A674871.4090901@vyatta.com>
References: <Pine.LNX.4.64.0907221032290.2211@zuben.voltaire.com>	 <60230E21F17E384C9BF0B9C98D9E3FDC04BDC92E@sgp-sg-mb02.sgp.agilent.com>	 <Pine.LNX.4.64.0907221448570.18880@tyr.diku.dk> <1248275552.4058.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, jon_zhou@agilent.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52690 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753963AbZGVRMI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 13:12:08 -0400
In-Reply-To: <1248275552.4058.0.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Wed, 2009-07-22 at 14:56 +0200, Jesper Dangaard Brouer wrote:
>> On Wed, 22 Jul 2009, jon_zhou@agilent.com wrote:
>>
>>> anyone knows the maximal speed of pktgen with 1Gbps NIC?
>> You are limited by the number of packets per second (pps) your machine can 
>> generate.  This limitation is given by the CPU speed and the NIC used.
>>
>> The maximum pps I have seen with pktgen at 1Gbit/s is 1200 kpps.
>>
>> 1Gbit/s wire speed pps with 64 bytes packets is approx 1953 kpps.
>> (1000*10^6/(64*8) = 1953125)
> [...]
> 
> You need to take the inter-packet gap into consideration too.

Yes.  Usually when people talk about the "64-byte PPS rate" they are 
referring to the maximum rate of minimum size ethernet frames.  The 
64-bytes includes the src/dst addr fields, type field and CRC, but does 
not include the preamble (7 bytes), SOF (1 byte) or IPG (12 bytes). 
Adding these in  gives a minimum size frame of 84 bytes.  This works out 
to a max rate of ( 1,000,000,000 / (84 * 8) ) = 1,488,095 PPS.

Bob.

