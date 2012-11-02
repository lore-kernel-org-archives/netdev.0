From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH v2 2/3] net: set and query VEB/VEPA bridge mode
 via PF_BRIDGE
Date: Fri, 02 Nov 2012 16:03:01 -0700
Message-ID: <50945125.1040103@intel.com>
References: <20121024181033.14378.33097.stgit@jf-dev1-dcblab>   <20121024181303.14378.78253.stgit@jf-dev1-dcblab>  <1351895923.2703.11.camel@bwh-desktop.uk.solarflarecom.com>  <50944DC0.5060209@intel.com> <1351897261.2703.21.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, buytenh@wantstofly.org, davem@davemloft.net,
	vyasevic@redhat.com, jhs@mojatatu.com, chrisw@redhat.com,
	krkumar2@in.ibm.com, samudrala@us.ibm.com,
	peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	eilong@broadcom.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59802 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776Ab2KBXDH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2012 19:03:07 -0400
In-Reply-To: <1351897261.2703.21.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/2012 4:01 PM, Ben Hutchings wrote:
> On Fri, 2012-11-02 at 15:48 -0700, John Fastabend wrote:
>> On 11/2/2012 3:38 PM, Ben Hutchings wrote:
>>> On Wed, 2012-10-24 at 11:13 -0700, John Fastabend wrote:
>>>> Hardware switches may support enabling and disabling the
>>>> loopback switch which puts the device in a VEPA mode defined
>>>> in the IEEE 802.1Qbg specification. In this mode frames are
>>>> not switched in the hardware but sent directly to the switch.
>>>> SR-IOV capable NICs will likely support this mode I am
>>>> aware of at least two such devices. Also I am told (but don't
>>>> have any of this hardware available) that there are devices
>>>> that only support VEPA modes. In these cases it is important
>>>> at a minimum to be able to query these attributes.
>>>>
>>>> This patch adds an additional IFLA_BRIDGE_MODE attribute that can be
>>>> set and dumped via the PF_BRIDGE:{SET|GET}LINK operations. Also
>>>> anticipating bridge attributes that may be common for both embedded
>>>> bridges and software bridges this adds a flags attribute
>>>> IFLA_BRIDGE_FLAGS currently used to determine if the command or event
>>>> is being generated to/from an embedded bridge or software bridge.
>>>> Finally, the event generation is pulled out of the bridge module and
>>>> into rtnetlink proper.
> [...]
>>>> +	if (attr && nla_type(attr) == IFLA_BRIDGE_FLAGS)
>>>
>>> This condition is wrong; attr will *not* be NULL if the
>>> nla_for_each_nested() loop terminates without finding an
>>> IFLA_BRIDGE_FLAGS attribute.
>>
>> It might be NULL if the nlmsg has no IFLA_AF_SPEC attr. In this case
>> we still need to send the PROTINFO attribute to the master which
>> could be the linux bridge.
> [...]
>
> I think nla_for_each_nested() can leave attr non-null but also not valid
> for use with nla_type().  And that's a problem.  I think it would be
> better to use an explicit flag for whether we found that attribute,
> rather than trying to re-test here.
>
> Ben.
>

OK. I'll add an explicit flag for this. Thanks.
