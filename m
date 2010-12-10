From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: slightly simplify keeping IPv6 addresses on link down
Date: Fri, 10 Dec 2010 15:00:22 -0800
Message-ID: <AANLkTikdmsPRJJFhLs4gboPaAsCA0U1UE3Xd1eePT3Zp@mail.gmail.com>
References: <20101201122253.2a8be2e0@nehalam> <AANLkTin5f+BZnFEzuc6iPLC8Hp++V0Jam8aAU2jMvxQq@mail.gmail.com>
 <20101201130421.0ac08bcd@nehalam> <20101210.124339.242120993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:49807 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618Ab0LJXAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:00:45 -0500
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id oBAN0hqd011591
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 15:00:43 -0800
Received: from gxk10 (gxk10.prod.google.com [10.202.11.10])
	by kpbe13.cbf.corp.google.com with ESMTP id oBAN0gSV020487
	for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 15:00:42 -0800
Received: by gxk10 with SMTP id 10so2354155gxk.40
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 15:00:42 -0800 (PST)
In-Reply-To: <20101210.124339.242120993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 12:43 PM, David Miller <davem@davemloft.net> wrote:
> Lorenzo you've already added serious bugs to this code with your
> previous address handling changes (which had reference counting bugs),
> so I'm going to heavily scrutinize any "cleanup" or other kind of
> change you try to make here.

By all means. Apologies for introducing the bug. Needless to say, I'll
let this one lie.

> In fact I really wish you would just leave this code as-is instead
> of trying to make such pointless tweaks to it.

My intention was to make the code a little more readable, and I did
test this by running it, but yes, a bug is a bug. As you can probably
tell, my expertise is in networking, not in writing kernel code. But I
do think that this code does the wrong thing in some areas, so I
wanted to try to fix it. In particular, keeping invalid autoconfig
addresses and routes configured on interfaces is guaranteed to break
connectivity.

I have two other patches that I think will improve the behaviour of
the stack from a networking perspective. One of them makes the kernel
properly update the lifetime of temporary addresses (this changed
between RFC 3041 and RFC 4941). The other deprecates addresses when
link goes down, which will do pretty much the same as my original
patch to delete the addresses, but will not cause the loss of any
privacy addresses configured.

My plan was to let these soak on my laptop (which I have been doing
for a few weeks), show them to colleagues who write kernel code (which
I have done), and submit them to this list. Is there anything else I
should be doing?

Thanks,
Lorenzo
