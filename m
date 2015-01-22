From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 09:10:19 -0800
Message-ID: <54C12EFB.3000004@gmail.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32> <20150122125246.GA4486@salvia> <20150122133713.GA25797@casper.infradead.org> <20150122140022.GA5674@salvia> <54C11094.2000807@mojatatu.com> <20150122151316.GB25797@casper.infradead.org> <54C11703.7030702@mojatatu.com> <20150122153727.GC25797@casper.infradead.org> <20150122164951.GA3417@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:38998 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630AbbAVRKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 12:10:36 -0500
Received: by mail-ob0-f177.google.com with SMTP id uy5so2496696obc.8
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 09:10:36 -0800 (PST)
In-Reply-To: <20150122164951.GA3417@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 08:49 AM, Pablo Neira Ayuso wrote:
> On Thu, Jan 22, 2015 at 03:37:27PM +0000, Thomas Graf wrote:
>> On 01/22/15 at 10:28am, Jamal Hadi Salim wrote:
>>> On 01/22/15 10:13, Thomas Graf wrote:
>>>
>>>> I don't follow this. John's proposal allows to decide on a case by
>>>> case basis what we want to export. Just like with ethtool or
>>>> RTNETLINK. There is no direct access to hardware. A user can only
>>>> configure what is being exposed by the kernel.
>>>>
>>>
>>> So if i am a vendor with my own driver, I can expose whatever i want.
>>
>> No. We will reject any driver change attempting to do so on this
>> list.
>
> I think those vendors do not want to push those driver changes
> mainstream. They will likely use these new ndo's to fully expose their
> vendor-specific capabilities distributed in proprietary blobs.
>
> I remember to have seen one ugly patch for netfilter that added
> several hook functions (not netfilter hooks) at different positions of
> the NAT code, the goal was to offload NAT through hardware. I was told
> the code that was using those ad-hoc hooks was distributed in a binary
> blob.
>
>> This is the whole point of this: Coming up with a model that allows
>> to describe capabilities and offer flow programming capabilities
>> in a Vendor neutral way. A "push_vlan" or "pop_vlan" action will work
>> with any driver that supports it.
>
> Right, we need an abstraction for actions too, and the infrastructure
> should not provide any means to circunvent and expose vendor specific
> details.
>

I'm not sure what a vendor specific detail is in the API now?

The API provides a mechanism to define the headers you support in a
vendor neutral way. Perhaps vendor X may be the only hardware to
support the packet type but the packets are not really vendor specific
if we have the packet layout we can generate code to create the packets
if we care to in software and find it useful.

Maybe the issue is the actions look like UIDs without any specification
as to what they do? The concern being as a vendor I could create an
action and call it my_vendor_specific_action and if I never tell anyone
how to use it then we are stuck.

I can add a set of specifier attributes to the get_action call that
describes actions using basic primitives to resolve this specific issue.
Actions should either 'set' fields, 'get' fields, 'dec' fields, 'inc'
fields, etc. Then you specify an action by providing the list of
operations it performs. So set_group_id is simply

	'set_field uid=group_id_metadata'

More complicated actions exist like route() and such which will be a
list of operations that may set multiple fields in a single atomic step.

The table API also seems vendor neutral to me. I'm not sure what
specific details would be vendor specific here either.

.John



-- 
John Fastabend         Intel Corporation
