From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Wed, 06 Jun 2007 17:35:02 +0200
Message-ID: <4666D426.2070606@trash.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>	<m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>	<46669FA0.3030405@trash.net> <m1d509umtp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, tgraf@suug.ch
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56389 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756099AbXFFPfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 11:35:30 -0400
In-Reply-To: <m1d509umtp.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>>You don't really need to patch it, installing a new iplink_XXX.so
>>file is enough. Generalizing driver specific options more than
>>what we currently have doesn't look very promising. I think your
>>driver was simple enough to get along with the generic device
>>attributes though (IFLA_LINK or IFLA_MASTER).
> 
> 
> I need to know the other device in the pair of devices I am creating.
> If ifindex was selectable IFLA_LINK or IFLA_MASTER might be
> interesting however they are currently are not, and I'm not quite
> certain about letting a user select the ifindex.  Although there may
> come a point when dealing with migration when it makes sense.


It shouldn't be very hard to implement, so far I just didn't see
any use for it.

> Hmm.  I guess if I had a reasonable default I could find out the
> pair device by looking at the returned NEW_LINK message.
> 
> Looking more close.  IFLA_MASTER does not work because I don't
> have a master/slave relationship.
> 
> IFLA_LINK looks like it will work.  I don't precisely match the
> semantics though which makes me nervous.  In particular my other
> device is not something I am sending through but what I am sending
> to.  The way the IPv6 code uses iflink to get the link local address
> starting with the hardware address of the iflink would be completely
> the wrong thing to do in my case.  Now my device won't have the magic
> IPv6 tunnel arp type so that code won't trigger.  Still it is
> a challenge.
> 
> I still think adding a IFLA_PARTNER or a custom attribute is cleaner
> in this case.  Slight semantic mismatches are the worst design bugs
> to correct.


Indeed, IFLA_PARTNER sounds like a better idea. I just suggested to
Pavel to create only a single device per newlink operation and binding
them later, what do you think about that?

>>>I do think we should specify the IFLA_KIND (was: IFLA_NAME) values in
>>>a header file.  So it is easy to get a list of all of the different
>>>kinds and so we don't conflict.
>>
>>
>>I don't think conflicts are going to be a problem (it would be
>>nice if modpost would warn about duplicate aliases though).
>>How is listing IFLA_KIND types in a header file going to help
>>get a list? Presuming the user knows what kind of device he
>>wants to set up and is not just looking for things to play
>>around with I also don't see any real value in this.
> 
> 
> This isn't about the user this is about maintaining the ABI.
> 
> We have to control set of strings for IFLA_KIND.  Having them all
> in a single header file means that we can easily look when we add
> support for a new kind to see if some other driver has already
> used that kind.
> 
> The same reason we stick the rest of the enumerations into a header
> file.
> 
> Strings don't conflict as easily as small integers do, but it is still
> possible to have a conflict, so having something like an ifla_kind.h to
> hold them would be useful.


Mhh .. we have multiple string based APIs that do just fine. I'd
prefer having someone adding a new driver do a quick grep for
MODULE_ALIAS_RTNL_LINK to adding unused definitions.

