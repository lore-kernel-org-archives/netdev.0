From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-2.6 PATCH 1/2] net: dcbnl: remove redundant DCB_CAP_DCBX_STATIC
 bit
Date: Mon, 24 Jan 2011 07:52:48 -0800
Message-ID: <4D3DA050.3020006@intel.com>
References: <20110122023512.4239.40379.stgit@jf-dev1-dcblab> <4D3A465F.8020809@intel.com> <1295801600.25104.13.camel@lb-tlvb-shmulik.il.broadcom.com> <4D3D123F.40700@intel.com> <1295882871.25104.20.camel@lb-tlvb-shmulik.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shmulik Ravid <shmulikr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:48301 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753281Ab1AXPwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jan 2011 10:52:49 -0500
In-Reply-To: <1295882871.25104.20.camel@lb-tlvb-shmulik.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/24/2011 7:27 AM, Shmulik Ravid wrote:
> 
> On Sun, 2011-01-23 at 21:46 -0800, John Fastabend wrote:
>> On 1/23/2011 8:53 AM, Shmulik Ravid wrote:
>>>
>>> On Fri, 2011-01-21 at 18:52 -0800, John Fastabend wrote:
>>>> On 1/21/2011 6:35 PM, John Fastabend wrote:
>>>>> Remove redundant DCB_CAP_DCBX_STATIC bit in DCB capabilities
>>>>>
>>>>> Setting this bit indicates that no embedded DCBx engine is
>>>>> present and the hardware can not be configured. This is the
>>>>> same as having none of the DCB capability flags set or simply
>>>>> not implementing the dcbnl ops at all.
>>>>>
>>>>> This patch removes this bit. The bit has not made a stable
>>>>> release yet so removing it should not be an issue with
>>>>> existing apps.
>>>>>
>>>>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>>>>> CC: Shmulik Ravid <shmulikr@broadcom.com>
>>>>> ---
>>>>>
>>>>

Dave, Please drop this patch sorry for the noise.

[...]

>> We have an advertise bit in userspace that can be set and cleared to
>> do something similar for host based agents. I think for pg and application
>> data you can get the same behavior by setting the device to not willing.
>>
> True, but this requires a proper DCBx peer. The STATIC option is a bit
> stronger.

At least in the PG case the CEE spec says the local configuration should be
used[1]. Application is a bit more vague in my opinion[2].

> 
>> However for PFC it could potentially be useful. But how would the
>> user set this mode? This is a capabilities bit indicating the device
>> supports this. Is there a way to subsequently put the device in this
>> mode?
> You can set this mode by specifying this attribute in the set_dcbx
> operation. The input to set_dcbx should be a subset of the advertised
> dcbx attributes.
> 

OK This works for me Shmulik thanks for the explanation.

[1] 3.1.4. http://www.ieee802.org/1/files/public/docs2008/az-wadekar-dcbx-capability-exchange-discovery-protocol-1108-v1.01.pdf

[2] 3.3.2. http://www.ieee802.org/1/files/public/docs2008/az-wadekar-dcbx-capability-exchange-discovery-protocol-1108-v1.01.pdf
