From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Wed, 18 Feb 2009 13:33:42 -0500
Message-ID: <499C5486.5020807@hp.com>
References: <200902172001.41804.arvidjaar@mail.ru> <20090217.142946.232071526.davem@davemloft.net> <25143.1234932076@turing-police.cc.vt.edu> <20090217.212919.259912220.davem@davemloft.net> <20090218135537.GF3600@mini-me.lan> <06F54D7E-EE07-49C9-AD8F-B46BD6B02ABA@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Theodore Tso <tytso@mit.edu>, David Miller <davem@davemloft.net>,
	Valdis.Kletnieks@vt.edu, arvidjaar@mail.ru, rjw@sisk.pl,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	jamagallon@ono.com, linux-kernel@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:9501 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754311AbZBRSdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 13:33:45 -0500
In-Reply-To: <06F54D7E-EE07-49C9-AD8F-B46BD6B02ABA@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> On Feb 18, 2009, at Feb 18, 2009, 8:55 AM, Theodore Tso wrote:
>> On Tue, Feb 17, 2009 at 09:29:19PM -0800, David Miller wrote:
>>> Next, if it's just an issue of IPV6 traffic, install a packet
>>> scheduler rule that rejects all packets with ethernet proto
>>> ETH_P_IPV6
>>>
>>> If openning up ipv6 sockets is problematic, that can be blocked
>>> using the security layer, which your super-duper distro kernel
>>> is guarenteed to have enabled. :-)
>>>
>>> I'm sure there is someone who has legacy problems with ipv4
>>> and that can't be disabled, and somehow people cope.  Amazing.
> 
> Here's another "me too".

And another "me too" for SCTP.  When IPv6 is turned on in the kernel
config file, we include the necessary pieces into the SCTP module and
sctp.ko will not load if ipv6.ko is blacklisted.

Having worked in other environments where ipv6 has to be explicitly
enabled per interface, I've thought that this level of control was
always missing from linux.  Being able to configure only the interface
that users want seems like a good thing to have.
Would a module parameter that disables ipv6 or at least addrconf be
enough of a solution?

-vlad

> 
> Kernel RPC support also has this problem.  We hit it just a couple of
> weeks ago now that we have IPv6 enabled NFS in prototype.  If PF_INET6
> listener creation fails (eg. because ipv6.ko is blacklisted), our
> workaround right now is to retry the listener socket creation with
> PF_INET.  There are plenty of somewhat rare corner cases that make this
> less than ideal.
> 
>> The reality is that there are far more people who have legacy problems
>> with ipv6 than ipv4 (which has been around and in active use for about
>> 3 decades, after all), whereas ipv6 has been around and largely
>> ignored for about a decade.  :-/
>>
>> I'll admit that I ran into some wierd sh*t problems with some open
>> source software or another failing mysteriously when IPv6 was enabled,
>> and I dealt with it by simply disabling IPv6 (yeah, I blocked the
>> module).  I was in a hurry, and it just didn't work, and I had better
>> thing to do than to spend time trying to debug why the presense of an
>> IPv6 enabled interface caused programs to misbehave in random ways.
>>
>> I think I can pretty much guarantee that distro users will be
>> clamoring for a quick and easy way to block ipv6, and it's in our
>> interest to document the recomended way to block it that doesn't cause
>> weird problems with bonding, etc.
> 
> A better solution would be to design kernel and user space networking to
> handle this use case, instead of providing a workaround.  From the
> variety of comments I've heard, this use case is pretty common.
> 
> Considering the government mandates requiring IPv6 support (and the
> advertisements by Linux vendors claiming IPv6 support), IPv6 needs to
> become a first-class citizen in Linux in fairly short order.  It still
> feels a little piecemeal to me to be called "production ready."
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

