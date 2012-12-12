From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Wed, 12 Dec 2012 13:11:02 -0800
Message-ID: <87zk1jht7d.fsf@xmission.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
	<87fw3boyxn.fsf@xmission.com> <50C8EEF0.2010201@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36807 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab2LLVLM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 16:11:12 -0500
In-Reply-To: <50C8EEF0.2010201@6wind.com> (Nicolas Dichtel's message of "Wed,
	12 Dec 2012 21:54:08 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 12/12/2012 20:25, Eric W. Biederman a =C3=A9crit :

>> Short answer you don't need to do any of this.
>>
>> setns with the namespace files in /proc/<pid>/ns/net gives you more =
than
>> enough mechanism to solve this problem.  And iprout2 already support=
s
>> all of this.
>>
>> And your approach creates very serious maintenances problems to the
>> point I don't even want to read your patches.  What namespace do you=
r
>> namespace id's live in?
>>
>> A socketopt to change the namespace of a socket is nasty because soc=
kets
>> changing which network namespace they are in, leads to races which
>> aren't worth thinking about writing the code to handle.
>>
>> Longer answer.
>>
>> You can bind mount the namespace id's /proc/<pid>/ns/net files to
>> give you any name you want.  This puts naming policy in userspace
>> control, and nests just fine.
>>
>> You can open a socket in any network namespace you want just
>> by calling setns before socket.  Wrapping this idiom in a library ca=
ll
>> or if there is sufficient need in a socketat system call seems
>> reasonable.
> Yes, I agree that this SO_NETNS may be a bad idea.
>
>>
>> There is a classic question of if two network namespace files refer =
to
>> the same network namespace and I have code in linux-next and my pull
>> request to Linus to give those files a unique inode number.
> Interesseting to know that.
>
>>
>> So please use the facilities already merged into the kernel.
> Ok, but how can a daemon get the list of netns? Suppose that we want =
that
> quagga manage all netns, how can it get this list to open needed netl=
ink
> socket?
>
> For example, iproute2 is only aware of netns created with iproute2, b=
ut it
> will no detect other netns.

iproute2 is only aware of network namespaces created with the conventio=
n
that iproute2 uses.

If you want other network namespaces to be visible globally use the sam=
e
or a similar convention. All iproute2 does is
"mount --bind /proc/<pid>/ns/net /var/run/netns/<name>".   So this
convention is not hard to follow.

It is very wrong to presume that without context you know the reason fo=
r
the exsitence of any network namespace and that you should or even that
you can manage it.  Think of running your multi-network namespace
managing application in a container.

Eric
