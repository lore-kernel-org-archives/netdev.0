From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [RFC PATCH 00/13] hardware time stamping + igb example	implementation
Date: Wed, 12 Nov 2008 19:44:14 +0100
Message-ID: <491B23FE.9000105@hartkopp.net>
References: <1226414697.17450.852.camel@ecld0pohly>	 <491AFF09.8070907@linux.intel.com> <1226507118.31699.91.camel@ecld0pohly>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:55975 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbYKLSo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 13:44:27 -0500
In-Reply-To: <1226507118.31699.91.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick Ohly wrote:
> On Wed, 2008-11-12 at 16:06 +0000, Andi Kleen wrote:
>   
>> As a general comment on the patch series I'm still a little sceptical
>> the time stamp offset method is a good idea. Since it tries to approximate
>> several unsynchronized clocks the result will always be of a little poor
>> quality, which will likely lead to problems sooner or later (or rather
>> require ugly workarounds in the user).
>>
>> I think it would be better to just bite the bullet and add new fields
>> for this to the skbs. Hardware timestamps are useful enough to justify
>> this.
>>     
>
> I'm all for it, as long as it doesn't keep this feature out of the
> mainline.
>
> At least one additional ktime_t field would be needed for the raw
> hardware time stamp. Transformation to system time (as needed by PTP)
> would have to be delayed until the packet is delivered via a socket. The
> code would be easier (and a bit more accurate) if also another ktime_t
> was added to store the transformed value directly after generating it.
>
> An extra field would also solve one of the open problems (tstamp set to
> time stamp when dev_start_xmit_hard is called for IP_MULTICAST_LOOP).
>
>   

I really wondered if you posted the series to get an impression why 
adding a new field is a good idea ;-)
Ok, i'm not that experienced on timestamps but i really got confused 
reading the patches and it's documentation (even together with the 
discussion on the ML). I would also vote for having a new field in the 
skb instead of this current 'bit-compression' approach which smells 
quite expensive at runtime and in code size. Not talking about the 
mentioned potential locking issues ...

Regards,
Oliver

