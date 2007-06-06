From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 11:31:02 -0600
Message-ID: <m1odjtt2g9.fsf@ebiederm.dsl.xmission.com>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>
	<46669FA0.3030405@trash.net>
	<m1d509umtp.fsf@ebiederm.dsl.xmission.com>
	<4666D426.2070606@trash.net> <20070606155634.GA15067@ms2.inr.ac.ru>
	<4666E1B2.1070109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org,
	socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42931 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756440AbXFFRdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 13:33:44 -0400
In-Reply-To: <4666E1B2.1070109@trash.net> (Patrick McHardy's message of "Wed,
	06 Jun 2007 18:32:50 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Alexey Kuznetsov wrote:
>>>						 I just suggested to
>>>Pavel to create only a single device per newlink operation and binding
>>>them later,
>> 
>> 
>> I see some logical inconsistency here.
>> 
>> Look, the second end is supposed to be in another namespace.
>> It will have identity, which cannot be expressed in any way in namespace,
>> which is allowed to create the pair: name, ifindex - nothing
>> is shared between namespaces.
>
>
> Good point, I didn't think of that. Is there a version of this patch
> that already uses different namespaces so I can look at it?

We have posted patches a couple of times, and veth or etun were always
a part of it.  But except for some book keeping details we really don't
care.

> Are network namespace completely seperated or is there some hierarchy
> with all lower namespaces visible above or something like that?

Completely separated.  The goal is to look like two separate machines
to user space, with respect to the network stack.

There is a bit of a hierarchy usage wise.  Because frequently only
one namespace will have real hardware devices in it.  So everything
needs to route through there.  But that detail is a usage detail
and is easiest not to reflect in the actual implementation.

> I imagined it more as a bind operation, pretty similar to enslave, so
> it would only contain an ifindex, no parameters. But as you say that
> doesn't work, so I guess we'd have to nest an entire ifinfomsg + the
> attributes for the partner device under it .. not exactly pretty.

In the model I'm working in, is that there is a separate operation:
"move device to other namespace", which should work for any network device.

So there should be an interval immediately after device creation
when both devices are in the same namespace, and then one of the
pair is moved to another namespace.

>> As response to this action two replies are generated: one RTM_NEWLINK
>> for one end of device with the whole desciption of partnet
>> is broadcasted inside this namespace, another RTM_NETLINK with index/name
>> of partner device is broadcasted inside the second namespace
>> (and, probably, some attributes, which must be hidden inside namespace,
>> f.e. identity of main device is suppressed). 
>
>
> The identity of the main device has no meaning within a different
> namespace, but are there other reasons for hiding it?

Not really.  We can already recognized the type of the device.

Eric

