From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 04/10] sysctl: Fix neighbour table sysctls.
Date: Thu, 09 Aug 2007 20:35:55 -0600
Message-ID: <m1k5s46rqs.fsf@ebiederm.dsl.xmission.com>
References: <20070809.184921.11594412.davem@davemloft.net>
	<20070810.111420.29442251.yoshfuji@linux-ipv6.org>
	<m1odhg6sbv.fsf@ebiederm.dsl.xmission.com>
	<20070810.112915.63714468.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=euc-jp
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, devel@openvz.org, adobriyan@sw.ru,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?euc-jp?B?tcjGo7HRzMA=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46131 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbXHJCgz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 22:36:55 -0400
In-Reply-To: <20070810.112915.63714468.yoshfuji@linux-ipv6.org> (YOSHIFUJI
	Hideaki's message of "Fri, 10 Aug 2007 11:29:15 +0900 (JST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.org> =
writes:

> In article <m1odhg6sbv.fsf@ebiederm.dsl.xmission.com> (at Thu, 09 Aug=
 2007
> 20:23:16 -0600), ebiederm@xmission.com (Eric W. Biederman) says:
>
>> YOSHIFUJI Hideaki / =B5=C8=C6=A3=B1=D1=CC=C0 <yoshfuji@linux-ipv6.or=
g> writes:
>>=20
>> > Would you explain why it does not work properly
>> > for those cases?
>>=20
>> Mostly no appropriate strategy routine was setup to=20
>> report the data to the caller of sys_sysctl.
>
> I assume that default strategy have been existing for it, no?!
> Maybe, I do miss something...

I'd have to go through it case by case.  But in general
unless your proc_handler is proc_dointvec the default
strategy routine which does a raw binary copy of your data
out will generally do the wrong thing.

So especially if your data is jiffies or otherwise needs
processing you don't want to use the default strategy
routine.

Until relatively recently no one was really policing the
sysctl interfaces and even now it isn't too serious.

Eric
