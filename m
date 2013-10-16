From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel side)
Date: Wed, 16 Oct 2013 12:53:11 -0700
Message-ID: <87txghm1qw.fsf@xmission.com>
References: <1380854061-30091-1-git-send-email-yamato@redhat.com>
	<20131008.152349.729447337097758010.davem@davemloft.net>
	<20131008141337.1a8a556c@nehalam.linuxnetplumber.net>
	<20131009165254.2e1c8332@nehalam.linuxnetplumber.net>
	<87li22vv1w.fsf@xmission.com> <525D7109.4010004@6wind.com>
	<87a9ias274.fsf@xmission.com> <525E659C.3000305@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, yamato@redhat.com,
	netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48560 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760844Ab3JPTxS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 15:53:18 -0400
In-Reply-To: <525E659C.3000305@6wind.com> (Nicolas Dichtel's message of "Wed,
	16 Oct 2013 12:08:28 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 15/10/2013 22:34, Eric W. Biederman a =C3=A9crit :

>> For IFLA_NET_NS_FD not that I know of.
>>
>> Mostly it is doable but there are some silly cases.
>> - Do we need to actually implement SCM_RIGHTS to prevent people
>>    accepting file-descriptors unknowingly and hitting their file
>>    descriptor limits.
>>
>>    In which case we need to call the attribute IFLA_NET_NS_SCM_FD
>>    so we knew it was just an index into the passed file descriptors.=
n
>>
>> - Do we need an extra permission check to prevent keeping a network
>>    namespace alive longer than necessary?  Aka there are some permis=
sion
>>    checks opening and bind mounting /proc/<pid>/ns/net do we need
>>    a similar check.  Perhaps we would need to require CAP_NET_ADMIN =
over
>>    the target network namespace.
>>
>> Beyond that it is just the logistics to open what is essentially
>> /proc/<pid>/ns/net and add it to the file descriptor table of the
>> requesting process.  Exactly which mount of proc we are going to
>> find the appropriate file to open I don't know.
>>
>> It isn't likely to be lots of code but it is code that the necessary
>> infrastructure is not in place for, and a bunch of moderately hairy
>> corner cases to deal with.
> Got it. This doesn't seems the simpliest/best way to resolve this pb.
> Can we not introduce another identifier (something like IFLA_NET_NS_I=
D),
> which will not have such constraint?
> inode is unique on the system, why not using it as an opaque value to
> identitfy the netns (like 'ip netns identify' do)?

The age old question why can't we have global identifiers for
namespaces?

The answer is that I don't want to implement a namespace for namespaces=
=2E

While the proc inode does work today across different mounts of proc, I
reserve the right at some future date (if it solves a technical problem=
)
to give each namespace a different inode number in each different mount
of proc.  So the inode number is not quite the unique identifier you
want.  The inode number is a close as I am willing to get to a namespac=
e
of namespaces.

I think the simplest solution is to just not worry about which namespac=
e
the other half of a veth pair is in.  But I have not encountered the
problem where I need to know exactly which namespace we are worrying
about.

Global identifiers are easy until you hit the cases where they make
things impossible.

Eric
