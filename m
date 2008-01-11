From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [klibc] [patch] import socket defines
Date: Fri, 11 Jan 2008 00:00:31 -0800
Message-ID: <4787221F.3030201@zytor.com>
References: <477BD374.6060506@zytor.com> <200801110207.39736.vapier@gentoo.org> <4787164F.9030805@zytor.com> <200801110257.42272.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klibc@zytor.com
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:48562 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbYAKIFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 03:05:16 -0500
In-Reply-To: <200801110257.42272.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Frysinger wrote:
>> all this stuff is ABI constants, and the only reason glibc 
>> doesn't use them is that glibc prefers to use enums over #defines.
> 
> a proper libc defines things in their headers according to the POSIX specs 
> rather than relying on others to do it for them.  if you want to argue about 
> linux-specific ABI pieces being exported, then you probably have a valid 
> point, but socket.h is hardly that.

Have you looked at it?!!?  It's full of ABI constants, and that's what I 
care about.  POSIX doesn't define, say, AF_UNIX; that's an ABI specific.

> so if the only consumer is klibc and you're against adding these things to it, 
> special case it for __KLIBC__.

No, let's split the header so that there are *no* libc knowledge in the 
kernel.  For the kernel to have knowledge about the specifics of any 
particular libc (klibc, glibc, or any other) is stupid, and that's the 
whole reason we're in this spot to begin with.

Again, I don't particularly care about what they're named, but the whole 
point is

	#include <linux/foo.h>

if you want the subset and

	#include <linux/bar.h>

if you want the whole set.

No libc specifics, and no feature test macros, which I think we can both 
agree are uglier than hell.

I thought the naming worked out nicer with <linux/sockaddr.h>, but I 
*don't really care*.

	-hpa
