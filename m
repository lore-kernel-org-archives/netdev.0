From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel
 side)
Date: Fri, 18 Oct 2013 17:34:36 +0200
Message-ID: <5261550C.6010403@6wind.com>
References: <1380854061-30091-1-git-send-email-yamato@redhat.com>	<20131008.152349.729447337097758010.davem@davemloft.net>	<20131008141337.1a8a556c@nehalam.linuxnetplumber.net>	<20131009165254.2e1c8332@nehalam.linuxnetplumber.net>	<87li22vv1w.fsf@xmission.com> <525D7109.4010004@6wind.com>	<87a9ias274.fsf@xmission.com> <525E659C.3000305@6wind.com>	<87txghm1qw.fsf@xmission.com> <52600ABC.1030701@6wind.com> <8738nzelxl.fsf@xmission.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, yamato@redhat.com,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:61276 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163Ab3JRPem (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:34:42 -0400
Received: by mail-wg0-f54.google.com with SMTP id c11so3890383wgh.21
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:34:40 -0700 (PDT)
In-Reply-To: <8738nzelxl.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 17/10/2013 21:28, Eric W. Biederman a =C3=A9crit :
> Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:
>
>> Le 16/10/2013 21:53, Eric W. Biederman a =C3=A9crit :
>
>>> The age old question why can't we have global identifiers for
>>> namespaces?
>>>
>>> The answer is that I don't want to implement a namespace for namesp=
aces.
>> Sorry, but I don't understand the problem. This ID is owned by the k=
ernel, like
>> the netns list (for_each_net()) is owned by it.
>
> The scenario where problem are likely to show up is something like th=
is.
>
> For testing it would be reasonable to setup two linux containers that
> look like full linux systems.  In those containers you run one instan=
ce
> of your virtual router managment daemons, and you arrange to synchron=
ize
> between the two linux containers for testing.
>
> It becomes even more interesting when we want to migrate one of those
> linux containers to another physical machine.
>
> Global identifiers start breaking the first scenario, and really tras=
h
> the second scenario.
>
> At the same time migration of configuration and replication of
> configuration are essentially the same problem, so it would be very
> silly to design such that will cause problems.
Ok, I'm now convinced ;-)

>
>>> While the proc inode does work today across different mounts of pro=
c, I
>>> reserve the right at some future date (if it solves a technical pro=
blem)
>>> to give each namespace a different inode number in each different m=
ount
>>> of proc.  So the inode number is not quite the unique identifier yo=
u
>>> want.  The inode number is a close as I am willing to get to a name=
space
>>> of namespaces.
>>>
>>> I think the simplest solution is to just not worry about which name=
space
>>> the other half of a veth pair is in.  But I have not encountered th=
e
>>> problem where I need to know exactly which namespace we are worryin=
g
>>> about.
>> Ok, let's start by explaining our usecase.
>>
>> We are using namespaces only to implement virtual routers (VR), ie o=
nly
>> the networking stack is virtualized. We don't care about other names=
paces, we
>> just want to run several network stacks and beeing able to manage th=
em.
>>
>> For example, providers use this feature to isolate clients, one VR i=
s opened
>> for each client. You can have a large number of clients (+10 000) an=
d thus the
>> same number of netns.
>> Considering these numbers, we don't want to run one instance per VR =
for all of
>> our network daemons, but have only one instance that manage all VR.
>>
>> You also have daemons that monitor the system and synchronize networ=
k objects
>> (interfaces, routes, etc.) on another linux. Goal is to implement an=
 high
>> availablity system: it's possible to switch to the other linux to av=
oid service
>> interruption.
>> This kind of daemon wants to have the full information about interfa=
ces to be
>> able to build/configure them on the other linux.
>>
>>>
>>> Global identifiers are easy until you hit the cases where they make
>>> things impossible.
>> I don't want specially to use ID, but I fear that the solution with =
file
>> descriptors will be a nightmare.
>
> I can certainly see challenges.  In asking for symmetry between set a=
nd
> get the solution with file descriptors is the obvious answer and the
> first answer I have been able to come up with so far.
>
> My original answer was that the ifindex happened to be unique across
> namespaces but that actually turned out to be a problem for migration
> so that abandoned.
>
> Namespace file descriptors are the solution that I know semantically
> will work.  Beyond that I don't have any good ideas right now.
>
> I just know that local names (aka file descriptors) are much easier t=
o
> work with semantically than global names.
Yes sure. I will continue to think about this.


Thank you,
Nicolas
