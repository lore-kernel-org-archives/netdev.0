From: "Ohly, Patrick" <patrick.ohly@intel.com>
Subject: RE: [RFC PATCH 00/13] hardware time stamping + igb example
 implementation
Date: Thu, 13 Nov 2008 16:05:21 +0000
Message-ID: <5B860B0D7BC1B74498C0C6D8C6E39A4F1E2FFA1E@irsmsx503.ger.corp.intel.com>
References: <1226414697.17450.852.camel@ecld0pohly>
	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly>
 <491B23FE.9000105@hartkopp.net> <491B2D03.1090700@cosmosbay.com>
 <491B3B49.7070402@linux.intel.com> <491B42FF.3000407@cosmosbay.com>
 <491B4BE3.3010104@linux.intel.com> <491BC614.9050201@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Andi Kleen <ak@linux.intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:35988 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbYKMQF0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 11:05:26 -0500
In-Reply-To: <491BC614.9050201@hartkopp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
> one question about a new crazy idea:
> 
> If we would tend to add new space in the skb, won't 4 bytes enough then?
> 
> A 32 bit value gives a nsec resolution of 4.294967296 seconds or +/- 
> 2.147483648 seconds.
> 
> If we make a 'full qualified' 64 bit sys-timestamp available anyway, the 
> new 32 bit value could be used as an offest (or it could be given to the 
> userspace directly) to calculate the hw timestamp within the 
> sys-timestamp context, right?

The sys-timestamp is normally not generated. The offset scheme would
add a call to gettimeofdayns() even if there is no other use for the
value. This might be acceptable; the bigger problem IMHO is that without
tracking system time in the hardware, hardware and system time will quickly
(~ a few days with the hardware I was looking at, if I remember correctly)
diverge more than can be stored in the 32 bit offset.

I'd prefer to spend 64 bits and be done without the need for further
encoding hacks.

Bye, Patrick
