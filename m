From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next-2.6 1/2] dcbnl: add support for retrieving peer
 configuration - ieee
Date: Thu, 24 Feb 2011 20:58:21 -0800
Message-ID: <4D6736ED.2060003@intel.com>
References: <1298581410.8877.21.camel@lb-tlvb-shmulik.il.broadcom.com> <4D66C186.7040409@intel.com> <A31CB8AA22AA1E44B81563BEDB2C187812203E0F8C@SJEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Eilon Greenstein <eilong@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid - Rabinovitz <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:49646 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753033Ab1BYE6W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 23:58:22 -0500
In-Reply-To: <A31CB8AA22AA1E44B81563BEDB2C187812203E0F8C@SJEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/24/2011 2:03 PM, Shmulik Ravid - Rabinovitz wrote:
>> -----Original Message-----
>> From: John Fastabend [mailto:john.r.fastabend@intel.com]
>> Sent: Thursday, February 24, 2011 10:37 PM
>> To: Shmulik Ravid - Rabinovitz
>> Cc: davem@davemloft.net; Eilon Greenstein; netdev@vger.kernel.org
>> Subject: Re: [PATCH net-next-2.6 1/2] dcbnl: add support for retrieving
>> peer configuration - ieee
>>
>> On 2/24/2011 1:03 PM, Shmulik Ravid wrote:
>>> These 2 patches add the support for retrieving the remote or peer
>> DCBX
>>> configuration via dcbnl for embedded DCBX stacks. The peer
>> configuration
>>> is part of the DCBX MIB and is useful for debugging and diagnostics
>> of
>>> the overall DCB configuration. The first patch add this support for
>> IEEE
>>> 802.1Qaz standard the second patch add the same support for the older
>>> CEE standard.
>>>
>>> Signed-off-by: Shmulik Ravid <shmulikr@broadcom.com>
>>> ---
>>>  include/linux/dcbnl.h |   38 ++++++++++++++++++++++++++
>>>  include/net/dcbnl.h   |    5 +++
>>>  net/dcb/dcbnl.c       |   71
>> +++++++++++++++++++++++++++++++++++++++++++++++++
>>>  3 files changed, 114 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
>>> index 4c5b26e..3102185 100644
>>> --- a/include/linux/dcbnl.h
>>> +++ b/include/linux/dcbnl.h
>>> @@ -110,6 +110,22 @@ struct dcb_app {
>>>  	__u16	protocol;
>>>  };
>>>
>>> +/* This structure contains the APP feature information sent by the
>> peer.
>>> + * It is used for both the IEEE 802.1Qaz and the CEE flavors.
>>> + *
>>> + * @willing: willing bit in the peer APP tlv
>>> + * @error: error bit in the peer APP tlv
>>> + * @app_count: The number of objects in the peer APP table.
>>> + *
>>> + * In addition to this information the full peer APP tlv also
>> contains
>>> + * a table of 'app_count' APP objects defined above.
>>> + */
>>> +struct dcb_peer_app_info {
>>> +	__u8	willing;
>>> +	__u8	error;
>>> +	__u16	app_count;
>>> +};
>>> +
>>
>> The IEEE 802.1Qaz spec defines the APP TLV as informational
>> so there are no willing or error bits in this case. See
>> section D.2.12 of the 802.1Qaz draft.
>>
>> Can we drop these fields or do they have some other meaning
>> here?
>>
> OK, They are part of the CEE APP tlv though. 
> I wanted to share this structure between the 802.1Qaz and CEE so 
> I'll have a single driver handler that retrieve the number of
> peer apps. How about if we keep a single driver handler, but the
> APP info will be exposed to the user only with the CEE flavor.
> That is the PEER_APP attribute will be CEE specific ?
> 
> Shmulik 
> 

That seems fine to me. Either don't expose the struct as you
suggested or zero the fields while in IEEE mode.

John.
