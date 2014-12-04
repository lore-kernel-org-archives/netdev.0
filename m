From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 4 Dec 2014 22:10:41 +0100
Message-ID: <20141204211041.GN1861@nanopsycho.orion>
References: <87y4qne6if.fsf@x220.int.ebiederm.org>
 <20141204163024.GG1861@nanopsycho.orion>
 <87388v9ua6.fsf@x220.int.ebiederm.org>
 <20141204182451.GI1861@nanopsycho.orion>
 <87k327450a.fsf@x220.int.ebiederm.org>
 <20141204191926.GK1861@nanopsycho.orion>
 <87wq672p49.fsf@x220.int.ebiederm.org>
 <87h9xbxjrd.fsf@x220.int.ebiederm.org>
 <20141204202742.GM1861@nanopsycho.orion>
 <87388vw2xg.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:63456 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbaLDVKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 16:10:44 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so29326488wiw.4
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 13:10:43 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <87388vw2xg.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 04, 2014 at 09:55:07PM CET, ebiederm@xmission.com wrote:
>Jiri Pirko <jiri@resnulli.us> writes:
>
>> Thu, Dec 04, 2014 at 09:06:14PM CET, ebiederm@xmission.com wrote:
>>>ebiederm@xmission.com (Eric W. Biederman) writes:
>>>
>>>> Jiri Pirko <jiri@resnulli.us> writes:
>>>>
>>>>>>So this id needs to be globally unique?
>>>>>
>>>>> No. It is enough to be unique within a single system. It serves for no
>>>>> more than to find out 2 ids are same or not, no other info value.
>>>>>
>>>>> So when the drivers uses sane ids (like mac for example, or in case of
>>>>> rocker an id which is passed by qemu command line), the chances of
>>>>> collision are very very close to none (never say never).
>>>
>>>Thinking about what you said a little more.
>>>
>>>Two different sources of persistent numbers picking numbers by
>>>completely different algorithms can give you no assurance that you don't
>>>produce conflicts.
>>>
>>>The switch id as desisgned can not work.
>>>
>>>There are expected to be between 2**36 to 2**40 devices in this world.
>>>Your first switch id is a 64it number.  At the very best by the birthday
>>>pardox predicts there will be a conflict ever 2**32 devices or between
>>>2**4 and 2**8 devices in the world with conflicts.  If the ids are not
>>>randomly distributed (which they won't be) things could easily be much
>>>much worse.
>>>
>>>That is just good enough the code could get out there and run for years
>>>before you have the nightmare of having to fix all of userspace.   That
>>>is a nightmare no one needs.
>>>
>>>So please remove this broken code, and this broken concept from the
>>>kernel and go back to the drawing board.
>>
>> In that case the phys port id is broken in the same way. Let's rather
>> think about how to avoid conflicts for both. Given the fact the
>> conflicts should be avoided only on a single baremetal, that should be
>> doable (for (bad) example using driver name mixed with driver created
>> id).
>
>No.  phys_port_id is not broken in the same way, and phys_port_id does
>not have the same set of properties.
>
>phys_port_id's in practice all have an IEEE prefix that identifies the
>manufacturer and a manufacture assigned serial number.  Aka a mac
>address or a EUID-64.  What the mlx4 ethernet driver is doing retunring
>a 64bit EUID-64 I don't know.  If there are problems in the worst
>case issues with phys_port_id are fixable by simple driver tweaks,
>because fundamentally we are working with globally uniuqe identifiers.
>Well globally unique baring manufacturing bugs in eeproms.

Well the fact that phys_post_id's are now implemented mostly by putting
mac into it does not mean that other drivers cannot do it differently.
So once again, phys_port_id and phys_switch_id are the same in this
matter.

>
>
>
>I agree with you that the switch id concept can be saved.  But I think
>we should fix switch id before we export it to userspace so we don't
>have to break userspace later.
>
>My intuition says we want something like ifindex, but I am not at all
>certain how switch id is planned to be used.  Given that it is single
>box I don't expect you are sending it out over the wire.

No, it is not to be send out.

>
>*shrug*
>
>Why does switch id need to be persistent?  Why can't switch id be
>property like ifindex?

Well I can imagine that multiple ports of the same switch chip could be
passed through to the virtual machines (similar to SR-IOV pf/vf).

>
>What are the actual requirements.


They are actually very similar to phys_port_id. Therefore I made that
the same.



>
>Eric
