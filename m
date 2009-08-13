From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 17:02:53 -0400
Message-ID: <457D0D34-041E-43AE-BE31-241A19AA08B4@oracle.com>
References: <1250091560.6641.48.camel@fnki-nb00130> <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130> <4A843EF7.4010700@hp.com> <1250187034.28285.93.camel@Joe-Laptop.home> <4A847669.7050508@hp.com> <1250195675.28285.128.camel@Joe-Laptop.home>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:40303 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756290AbZHMVDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 17:03:35 -0400
In-Reply-To: <1250195675.28285.128.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Aug 13, 2009, at 4:34 PM, Joe Perches wrote:
> On Thu, 2009-08-13 at 16:24 -0400, Brian Haley wrote:
>> Is your arch "um"?  Seems like those are only defined there, I'm  
>> building
>> a straight x86 kernel.
>
> Nope.
>
> I did make allyesconfig ; make lib/vsprintf.o lib ctype.o
> allnoconfig works though.
>
>> This core dumps when running "test", I'm still trying to track down  
>> why.
>
> missing return on ip_addr_string
>
>> I think we're thinking too hard about this, I would think we'd always
>> want to print the shortened IPv6 address in debugging messages with  
>> %pI6.
>
> True, but you can't tell in sprintf as it's used in seq.
>
> for instance:
> net/sunrpc/svcauth_unix.c:		seq_printf(m, "%s %pI6 %s\n", im- 
> >m_class, &addr, dom);

This one might be a bad example.  RPC IPv6 support, especially server  
side, isn't written in stone yet.  User space may not even be ready  
for an IPv6 address here; I can check.  If user space happens to be  
flexible here, then it won't matter if this particular instance is  
shorthanded or not.

[ I would think user space in general should be using inet_pton(3)  
everywhere for such interfaces, so the format of these addresses  
wouldn't matter so much.  Probably impossible at this point. ]

>> The %pi6 places need to stay since they're an API to userspace.  I  
>> don't
>> think we need the extra "c" and "c4" support.
>
> I'm pretty sure it can't change and a new form is needed
> so %pi6c should be OK.
>
> I'd rather not use another %p<foo> letter.

I'm not arguing one way or the other, but it would be useful if  
someone could check exactly what the dependencies are right now.  It  
seems like we're speculating a bit.

>> One comment on a quick scan of the code:
>> ip6_addr[8 * 5] is fine here, we won't ever have all eight plus an  
>> IPv4 address.
>
> I'm fixing it up and will resubmit something working in a little  
> while.
>
> cheers, Joe

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
