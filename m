From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Thu, 13 Dec 2012 11:08:13 -0800
Message-ID: <87mwxh6a8y.fsf@xmission.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
	<87fw3boyxn.fsf@xmission.com> <50C8EEF0.2010201@6wind.com>
	<87zk1jht7d.fsf@xmission.com> <87sj7beyc1.fsf@xmission.com>
	<50CA135A.7060802@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:53111 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab2LMTIX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 14:08:23 -0500
In-Reply-To: <50CA135A.7060802@6wind.com> (Nicolas Dichtel's message of "Thu,
	13 Dec 2012 18:41:46 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> writes:

> Le 12/12/2012 22:48, Eric W. Biederman a =C3=A9crit :
>> ebiederm@xmission.com (Eric W. Biederman) writes:
>>
>>> It is very wrong to presume that without context you know the reaso=
n for
>>> the exsitence of any network namespace and that you should or even =
that
>>> you can manage it.  Think of running your multi-network namespace
>>> managing application in a container.
>>
>> A good example of a network namespace you don't want to mess with ar=
e
>> the network namespaces created by vsftp and chrome for security purp=
oses
>> to remove any possibility of creating new connections to the network=
=2E
>>
> Ok, I get the point.
>
> A last question: from an administration point of view, is it intended=
 to
> not be able to monitor which netns are currently used? Like it can be=
 done
> for sockets, files, ...

No.  The difficulty monitoring which network namespaces are being used
is an unintended side effect.

My pending changes to /proc/<pid>/ns/net and friends that allow you to
stat those files and compare if two network are the same network
namespace should make that monitoring much easier.  It isn't perfect as
there currently isn't a way to take a socket and say which network
namespace is this socket in.  But the current solution should tell you
what is happening most of the time.

struct net allocates it's own slab type so /proc/slabinfo on a good day
can tell you how many network namespace structures have been allocated
and are in use.

Eric
