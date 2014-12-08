From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Mon, 08 Dec 2014 15:56:06 -0600
Message-ID: <8761dlst55.fsf@x220.int.ebiederm.org>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
	<1417683438-10935-2-git-send-email-jiri@resnulli.us>
	<87y4qne6if.fsf@x220.int.ebiederm.org>
	<20141204163024.GG1861@nanopsycho.orion>
	<87388v9ua6.fsf@x220.int.ebiederm.org>
	<20141204182451.GI1861@nanopsycho.orion>
	<87k327450a.fsf@x220.int.ebiederm.org>
	<20141204191926.GK1861@nanopsycho.orion>
	<87wq672p49.fsf@x220.int.ebiederm.org>
	<87h9xbxjrd.fsf@x220.int.ebiederm.org>
	<20141204202742.GM1861@nanopsycho.orion>
	<87388vw2xg.fsf@x220.int.ebiederm.org>
	<063D6719AE5E284EB5DD2968C1650D6D1CA0339B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jiri Pirko <jiri@resnulli.us>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"nhorman\@tuxdriver.com" <nhorman@tuxdriver.com>,
	"andy\@greyhouse.net" <andy@greyhouse.net>,
	"tgraf\@suug.ch" <tgraf@suug.ch>,
	"dborkman\@redhat.com" <dborkman@redhat.com>,
	"ogerlitz\@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse\@nicira.com" <jesse@nicira.com>,
	"pshelar\@nicira.com" <pshelar@nicira.com>,
	"azhou\@nicira.com" <azhou@nicira.com>,
	"ben\@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen\@networkplumber.org" <stephen@networkplumber.org>,
	"jeffrey.t.kirsher\@intel.com" <jeffrey.t.kirsher@intel.com>,
	"vyasevic\@redhat.com" <vyasevic@redhat.com>,
	"xiyou.wangcong\@gmail.com" <xiyou.wangcong@gmail.com>,
	"john.r.fastabend\@intel.com" <john.r.fastabend@intel.com>,
	"edumazet\@google.com" <edumazet@google.com>,
	"jhs\@mojatatu.com" <jhs@
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48526 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088AbaLHV6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 16:58:31 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA0339B@AcuExch.aculab.com>
	(David Laight's message of "Fri, 5 Dec 2014 09:54:33 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:

> From: Eric W. Biederman
>> Jiri Pirko <jiri@resnulli.us> writes:
>> 
>> > Thu, Dec 04, 2014 at 09:06:14PM CET, ebiederm@xmission.com wrote:
>> >>ebiederm@xmission.com (Eric W. Biederman) writes:
>> >>
>> >>> Jiri Pirko <jiri@resnulli.us> writes:
>> >>>
>> >>>>>So this id needs to be globally unique?
>> >>>>
>> >>>> No. It is enough to be unique within a single system. It serves for no
>> >>>> more than to find out 2 ids are same or not, no other info value.
>> >>>>
>> >>>> So when the drivers uses sane ids (like mac for example, or in case of
>> >>>> rocker an id which is passed by qemu command line), the chances of
>> >>>> collision are very very close to none (never say never).
>> >>
>> >>Thinking about what you said a little more.
>> >>
>> >>Two different sources of persistent numbers picking numbers by
>> >>completely different algorithms can give you no assurance that you don't
>> >>produce conflicts.
>> >>
>> >>The switch id as desisgned can not work.
>> >>
>> >>There are expected to be between 2**36 to 2**40 devices in this world.
>> >>Your first switch id is a 64it number.  At the very best by the birthday
>> >>pardox predicts there will be a conflict ever 2**32 devices or between
>> >>2**4 and 2**8 devices in the world with conflicts.  If the ids are not
>> >>randomly distributed (which they won't be) things could easily be much
>> >>much worse.
>> >>
>> >>That is just good enough the code could get out there and run for years
>> >>before you have the nightmare of having to fix all of userspace.   That
>> >>is a nightmare no one needs.
>> >>
>> >>So please remove this broken code, and this broken concept from the
>> >>kernel and go back to the drawing board.
>> >
>> > In that case the phys port id is broken in the same way. Let's rather
>> > think about how to avoid conflicts for both. Given the fact the
>> > conflicts should be avoided only on a single baremetal, that should be
>> > doable (for (bad) example using driver name mixed with driver created
>> > id).
>> 
>> No.  phys_port_id is not broken in the same way, and phys_port_id does
>> not have the same set of properties.
>> 
>> phys_port_id's in practice all have an IEEE prefix that identifies the
>> manufacturer and a manufacture assigned serial number.  Aka a mac
>> address or a EUID-64.  What the mlx4 ethernet driver is doing retunring
>> a 64bit EUID-64 I don't know.  If there are problems in the worst
>> case issues with phys_port_id are fixable by simple driver tweaks,
>> because fundamentally we are working with globally uniuqe identifiers.
>> Well globally unique baring manufacturing bugs in eeproms.
>
> Manufacturers have to generate unique MAC addresses - otherwise people complain.
> But can't be assumed to put different 'serial numbers' in other devices.
> If you look at USB memory sticks you are likely to find that the serial
> number in the (equivalent of the) ATA identify response isn't unique.
> So I doubt you can use the value to distinguish between devices.

When I said serial number I was talking about MAC addresses.

> You also get the situation where ethernet MAC addresses only have to be
> unique within a collision domain. Many old sun systems used a single MAC
> address - valid because they assumed/required that multiple interfaces
> be connected to different networks.
> So even MAC addresses aren't per-interface.

The old sun system issue does not apply to switches and switch like
devices.

There are common layer two protocls (Spanning Tree? LACP?) that require
each switch port to have a unique mac address.  So people will complain
and software will break if there is not a mac address per port.  So for
switches and things that strongly resemble switches assuming a unique
mac address per port is a reasonable assumption.

Eric
