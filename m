From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch iproute2 1/6] iproute2: ipa: show switch id
Date: Thu, 04 Dec 2014 15:24:13 -0600
Message-ID: <871tofun0i.fsf@x220.int.ebiederm.org>
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
	<20141204211041.GN1861@nanopsycho.orion>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:51442 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbaLDV0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 16:26:37 -0500
In-Reply-To: <20141204211041.GN1861@nanopsycho.orion> (Jiri Pirko's message of
	"Thu, 4 Dec 2014 22:10:41 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

>>No.  phys_port_id is not broken in the same way, and phys_port_id does
>>not have the same set of properties.
>>
>>phys_port_id's in practice all have an IEEE prefix that identifies the
>>manufacturer and a manufacture assigned serial number.  Aka a mac
>>address or a EUID-64.  What the mlx4 ethernet driver is doing retunring
>>a 64bit EUID-64 I don't know.  If there are problems in the worst
>>case issues with phys_port_id are fixable by simple driver tweaks,
>>because fundamentally we are working with globally uniuqe identifiers.
>>Well globally unique baring manufacturing bugs in eeproms.
>
> Well the fact that phys_post_id's are now implemented mostly by putting
> mac into it does not mean that other drivers cannot do it differently.
> So once again, phys_port_id and phys_switch_id are the same in this
> matter.

No exclusively implemented that way.

And yes other drivers can implement bugs, that doesn't mean those bugs
will be toleraged and won't break userspace.

>>I agree with you that the switch id concept can be saved.  But I think
>>we should fix switch id before we export it to userspace so we don't
>>have to break userspace later.
>>
>>My intuition says we want something like ifindex, but I am not at all
>>certain how switch id is planned to be used.  Given that it is single
>>box I don't expect you are sending it out over the wire.
>
> No, it is not to be send out.
>
>>
>>*shrug*
>>
>>Why does switch id need to be persistent?  Why can't switch id be
>>property like ifindex?
>
> Well I can imagine that multiple ports of the same switch chip could be
> passed through to the virtual machines (similar to SR-IOV pf/vf).

In that case you do need something that is globally unique.  Because
if I migrate your virtual machine onto a different physical machine 
seeing the same switch id and I might make the mistaken assumption
that I am remain on the same switch if the ids are not global.

>>What are the actual requirements.
>
>
> They are actually very similar to phys_port_id. Therefore I made that
> the same.

Then please for rocket use a non-buggy implementation with a globally
unique id.

Given your descriptions of the requirements I can't see how any other
implementation isn't buggy.

Eric
