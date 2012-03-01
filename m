From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Thu, 01 Mar 2012 14:10:44 -0800
Message-ID: <4F4FF3E4.5010003@intel.com>
References: <1329225526.2806.34.camel@mojatatu> <4F3AAE80.4040609@intel.com> <1329315057.4158.15.camel@mojatatu> <4F3C5B44.7000608@intel.com> <1329488932.2272.19.camel@mojatatu> <4F3E8A01.5000205@intel.com> <1329568900.3027.0.camel@mojatatu> <4F4DAC26.4050108@intel.com> <1330523779.18226.17.camel@mojatatu> <4F4E5FA4.4040506@intel.com> <20120301141413.GB4430@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, chrisw@redhat.com, davem@davemloft.net,
	gregory.v.rose@intel.com, kvm@vger.kernel.org, sri@us.ibm.com,
	kernel@wantstofly.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61612 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758075Ab2CAWKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 17:10:46 -0500
In-Reply-To: <20120301141413.GB4430@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/2012 6:14 AM, Michael S. Tsirkin wrote:
> On Wed, Feb 29, 2012 at 09:25:56AM -0800, John Fastabend wrote:
>> Agreed. I think adding some ndo_ops for bridging offloads here would
>> work. For example the DSA infrastructure and/or macvlan devices might
>> need this. Along the lines of extending this RFC,
>>
>> [RFC] hardware bridging support for DSA switches
>> http://patchwork.ozlabs.org/patch/16578/
>>
>>
>> .John
> 
> One place where this might not work well would be
> macvtap which is not a network device so it doesn't have
> its own address, instead it inherits one from macvlan.
> 

But is macvtap really doing any forwarding or implementing any
RX filters? Took a quick scan and it looks like the forwarding
logic is all in the macvlan code paths. In this case I suspect
if we enable macvlan then any device built on top of it would
work.

.John
