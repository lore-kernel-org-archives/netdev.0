From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 04 Dec 2014 14:06:14 -0600
Message-ID: <87h9xbxjrd.fsf@x220.int.ebiederm.org>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
	<1417683438-10935-2-git-send-email-jiri@resnulli.us>
	<87y4qne6if.fsf@x220.int.ebiederm.org>
	<20141204163024.GG1861@nanopsycho.orion>
	<87388v9ua6.fsf@x220.int.ebiederm.org>
	<20141204182451.GI1861@nanopsycho.orion>
	<87k327450a.fsf@x220.int.ebiederm.org>
	<20141204191926.GK1861@nanopsycho.orion>
	<87wq672p49.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.c
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59482 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbaLDUIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 15:08:34 -0500
In-Reply-To: <87wq672p49.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 04 Dec 2014 13:26:14 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Jiri Pirko <jiri@resnulli.us> writes:
>
>>>So this id needs to be globally unique?
>>
>> No. It is enough to be unique within a single system. It serves for no
>> more than to find out 2 ids are same or not, no other info value.
>>
>> So when the drivers uses sane ids (like mac for example, or in case of
>> rocker an id which is passed by qemu command line), the chances of
>> collision are very very close to none (never say never).

Thinking about what you said a little more.

Two different sources of persistent numbers picking numbers by
completely different algorithms can give you no assurance that you don't
produce conflicts.

The switch id as desisgned can not work.

There are expected to be between 2**36 to 2**40 devices in this world.
Your first switch id is a 64it number.  At the very best by the birthday
pardox predicts there will be a conflict ever 2**32 devices or between
2**4 and 2**8 devices in the world with conflicts.  If the ids are not
randomly distributed (which they won't be) things could easily be much
much worse.

That is just good enough the code could get out there and run for years
before you have the nightmare of having to fix all of userspace.   That
is a nightmare no one needs.

So please remove this broken code, and this broken concept from the
kernel and go back to the drawing board.

Eric
