From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add compat ioctl support for the ipv4 multicast ioctl SIOCGETSGCNT
Date: Sun, 30 Jan 2011 10:15:40 -0800
Message-ID: <m18vy2tfzn.fsf@fess.ebiederm.org>
References: <m18vy3uof7.fsf@fess.ebiederm.org>
	<201101301326.14390.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49107 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab1A3SPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 13:15:52 -0500
In-Reply-To: <201101301326.14390.arnd@arndb.de> (Arnd Bergmann's message of
	"Sun, 30 Jan 2011 13:26:14 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> On Sunday 30 January 2011 03:15:56 Eric W. Biederman wrote:
>> A trivial compact ioctl implementation would conflict with:
>> SIOCAX25ADDUID
>> SIOCAIPXPRISLT
>> SIOCGETSGCNT_IN6
>> SIOCGETSGCNT
>> SIOCRSSCAUSE
>> SIOCX25SSUBSCRIP
>> SIOCX25SDTEFACILITIES
>
> Since you have compiled the list, did you see if these are all handled
> compatible, or would it make sense to create patches for the other
> protocols as well, to handle them individually?

I didn't look.  I had a specific pre-existing application that didn't
work, and those ioctls meant the existing solutions for network compat
ioctls wouldn't work and the infrastructure needed fixing.

>> +#ifdef CONFIG_COMPAT
>> +static int compat_raw_ioctl(struct sock *sk, unsigned int cmd, unsigned long arg)
>> +{
>> +	switch (cmd) {
>> +	case SIOCOUTQ:
>> +	case SIOCINQ:
>> +		return -ENOIOCTLCMD;
>
> I would have suggested doing
>
> 	return raw_ioctl(sk, cmd, (unsigned long)compat_ptr(arg));
>
> here, but returning -ENOIOCTLCMD is equivalent and correct. Your solution
> is slightly more compact, the other one would be slightly faster.

Correct and maintainable is fine by me.

Right now my network stack performance problems are almost all rtnl_lock
hold time problems.

Eric
