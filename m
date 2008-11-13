From: "Ohly, Patrick" <patrick.ohly@intel.com>
Subject: RE: [RFC PATCH 00/13] hardware time stamping + igb example
 implementation
Date: Thu, 13 Nov 2008 15:53:27 +0000
Message-ID: <5B860B0D7BC1B74498C0C6D8C6E39A4F1E2FF9E2@irsmsx503.ger.corp.intel.com>
References: <1226414697.17450.852.camel@ecld0pohly>
	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly>
 <491B23FE.9000105@hartkopp.net> <491B2D03.1090700@cosmosbay.com>
 <491B3B49.7070402@linux.intel.com> <491B42FF.3000407@cosmosbay.com>
 <491B4BE3.3010104@linux.intel.com> <491B581B.5090105@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Oliver Hartkopp <oliver@hartkopp.net>,
	Andi Kleen <ak@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56574 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420AbYKMPxj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 10:53:39 -0500
In-Reply-To: <491B581B.5090105@hartkopp.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
>Andi Kleen wrote:
>>Eric Dumazet wrote:
>>> I threw a "crazy idea", that can be changed if necessary, say with a 
>>> cookie
>>> that identifies the slot in NIC driver structure. O(1) lookup if 
>>> really needed.
>>
>> I think "crazy" describes it well because it would be a lot of dubious
>> and likely not performing well effort just to save 8 bytes.
>>
>
> The crazy idea from Eric looks easier and more clearly to me than the 
> discussed patch set from Patrick Ohly - but i wonder if we should give a 
> separate hw timestamp a try ...

For reasons that have been mentioned already here (some hardware can
time stamp every packet, new use cases) I think it would be important
to have the hwtstamp information right in the skb. I can change the
patch series so that it uses one additional ktime_t hwtstamp field; give
me a few days, I'm currently traveling.

> I know Patrick is not a friend of a CONFIG option here. But when we make 
> it right HW timestamp could only be disabled on CONFIG_EMBEDDED or 
> something like that.

I'm not a friend of a config option because it was suggested that
hardware tstamps should off on *standard* kernels. That's of little
use for users of unmodified distributions who want to run PTP.

If the feature is only disabled on special distributions, then I really
don't mind, but at the same time I wonder whether these distributions
are performance sensitive enough to care about the additional field.

Bye, Patrick
