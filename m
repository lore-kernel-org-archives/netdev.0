From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example	implementation
Date: Wed, 12 Nov 2008 23:26:35 +0100
Message-ID: <491B581B.5090105@hartkopp.net>
References: <1226414697.17450.852.camel@ecld0pohly>	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly> <491B23FE.9000105@hartkopp.net> <491B2D03.1090700@cosmosbay.com> <491B3B49.7070402@linux.intel.com> <491B42FF.3000407@cosmosbay.com> <491B4BE3.3010104@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Patrick Ohly <patrick.ohly@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Andi Kleen <ak@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:40047 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbYKLW0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 17:26:40 -0500
In-Reply-To: <491B4BE3.3010104@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Eric Dumazet wrote:
>
>> This scheme only is needed for special devices, 
>
> It's going to be supported by a large range of mass market NICs,
> not special devices.
>
> used by PTP.

HW Timestamps are also state-of-the-art in a large range of Controller 
Area Network (CAN) NICs.
And when you want to write 'really professional' traffic sniffers or you 
need to deal with sensor fusion, hw timestamps allow big improvements in 
reliability of the sensor information.

>
>> TCP trafic wont use hwtstamp. 
>
> Actually it wouldn't surprise me if one of the numerous
> TCP congestion avoidance algorithms that get added all the time
> starts making use of such an enhanced time stamp.
>

I would also assume that people will find new use-cases for hw 
timestamps once they are available.

>> I threw a "crazy idea", that can be changed if necessary, say with a 
>> cookie
>> that identifies the slot in NIC driver structure. O(1) lookup if 
>> really needed.
>
> I think "crazy" describes it well because it would be a lot of dubious
> and likely not performing well effort just to save 8 bytes.
>

The crazy idea from Eric looks easier and more clearly to me than the 
discussed patch set from Patrick Ohly - but i wonder if we should give a 
separate hw timestamp a try ...

I know Patrick is not a friend of a CONFIG option here. But when we make 
it right HW timestamp could only be disabled on CONFIG_EMBEDDED or 
something like that.

Regards,
Oliver

> BTW it wouldn't surprise me if skb heads had some free space in common
> situations anyways becaus it's unlikely it fits exactly into 4K pages
> in slab/slub.
>
> -Andi

