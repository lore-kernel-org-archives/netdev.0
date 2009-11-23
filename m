From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v7 5/7 RFC] TCPCT part 1e: implement socket
 option TCP_COOKIE_TRANSACTIONS
Date: Mon, 23 Nov 2009 06:16:03 -0500
Message-ID: <4B0A6EF3.8040302@gmail.com>
References: <4B06A1FF.8000202@gmail.com>	<4B06AC2C.3070102@gmail.com>	 <20091120.092651.254794724.davem@davemloft.net>  <4B08D967.80003@gmail.com> <1258873848.16503.12.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:52741 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbZKWLQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 06:16:08 -0500
Received: by gxk4 with SMTP id 4so11706806gxk.8
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2009 03:16:14 -0800 (PST)
In-Reply-To: <1258873848.16503.12.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Sun, 2009-11-22 at 01:25 -0500, William Allen Simpson wrote:
>> David Miller wrote:
>>> From: William Allen Simpson <william.allen.simpson@gmail.com>
>>> Date: Fri, 20 Nov 2009 09:48:12 -0500
>>>> +		if (ctd.tcpct_used > 0
>>>> +		 || (tp->cookie_values == NULL
>>>> +		  && (sysctl_tcp_cookie_size > 0
>>>> +		   || ctd.tcpct_cookie_desired > 0
>>>> +		   || ctd.tcpct_s_data_desired > 0))) {
>>> Please fix the conditional coding style, and the alignment of
>>> the lines, it's not right here.
> 
> I think the rather significantly majority style, especially
> for net/... is to use || and && at the end of the line rather
> than the start and it should be used.
> 
> Treewide:
> 
> $ grep -rP --include=*.[ch] "(\|\||\&\&)\s*$" * | wc -l
> 34180
> 
> $ grep -rP --include=*.[ch] "^\s*(\|\||\&\&)" * | wc -l
> 7855
> 
> net: 3859 to 382 (more than 10:1, so it's the one to follow)
> drivers/net: 4610 to 666
> 
Thanks for measuring.

I'll note that during the previous review back at the v4 round, you
(Joe) passed along a formerly private message from Linus expressing his
preference for variable lvalues:

   http://www.spinics.net/lists/netdev/msg111212.html

But my example code in that thread also had both leading && and || -- and
neither David nor Eric nor Ilpo nor you mentioned that as an issue in that
entire thread:

   http://www.spinics.net/lists/netdev/msg111172.html

In the previous plaint about lvalues, there were merely 500+ examples
using the same constant lvalue form as my code -- in arch, drivers, net,
and sound.  For this example, many *thousands* are found everywhere!

Therefore, it's plain as can be that this is just more jumping through
arbitrary and capricious hoops that others are not required to follow.


> Besides, it's the one David wants...
> 
At *thousands* of examples, including in the tcp*.c files themselves, it
really becomes obvious that that may be a personal preference of David,
but is *not* a tree-wide or even a net-wide coding style.

However, a private message to me nearly 2 months ago expressed:

   "As unpalatable as it may be, all the more reason to genuflect as
   required to get the changes into the net-next-2.6 tree so they will
   flow down to future distros."

I followed that advice for a month.  That last patch submitted for
inclusion was v4 on Oct 27th.  Then, as some have noticed, I quit using
the net-next tree for actual development.  I've only sent weekly RFC
versions to solicit more widespread comments from subject matter experts,
and keep the patch offsets in sync with the rapidly changing tree.

As a more recent private comment asked:

   "So your frustration is nothing but normal.  And guess what ? Few
   people accept the challenge, so keep trying !"

So, I'll try again now, with the assurance that this is the final hoop.
