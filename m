From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next 0/5] netns: allow to identify peer netns
Date: Tue, 15 Jul 2014 16:32:26 +0200
Message-ID: <53C53B7A.5000909@6wind.com>
References: <537327F1.4060603@6wind.com>	<1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com> <87simj7ca1.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:39115 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbaGOOca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 10:32:30 -0400
Received: by mail-we0-f182.google.com with SMTP id q59so5745456wes.13
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 07:32:28 -0700 (PDT)
In-Reply-To: <87simj7ca1.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/07/2014 22:09, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> The goal of this serie is to be able to multicast netlink messages w=
ith an
>> attribute that identify a peer netns.
>> This is needed by the userland to interpret some informations contai=
ned in
>> netlink messages (like IFLA_LINK value, but also some other attribut=
es in case
>> of x-netns netdevice (see also
>> http://thread.gmane.org/gmane.linux.network/315933/focus=3D316064)).
>>
>> Each network namespaces allocates its own ids for other netns (inclu=
ding
>> itself). The user can retrieve these ids via a new netlink messages,=
 but only
>> if he has a FD which points to this netns. Dump is not implemented s=
o that a
>> user cannot get the whole netns list.
>>
>> The goal of this RFC is mainly to validate the principle, ie patch 1=
/5 and 2/5.
>> Patch 3/5 and 4/5 shows an example of how to use these ids in rtnetl=
ink
>> messages. And patch 5/5 shows that the netlink messages can be symet=
ric between
>> a GET and a SET.
>
> This approach fundamentally breaks process migration, and calls for a
> namespace of namespaces.
Maybe there is no other solution. Network people uses netns to implemen=
t
"virtual router", ie only network namespaces are used. Userland daemons
manage a set of netns. These daemons need to be able to identify a peer=
 netns
when netlink messages from kernel are parsed. For now, these netlink me=
ssages
are incomplete and contain information that cannot be interpreted (like=
 the
IFLA_LINK ifindex).

Can you give me more details about the "process migration"? How does it=
 work
when you have a veth tunnel between two netns?

>
> Which means this is a major mess that really isn't going to work beca=
use
> it generates more problems than it solves.
It's just a netns inside another netns, or to be easier to figure out, =
one or
more virtual router inside a netns ;-)

Regards,
Nicolas
