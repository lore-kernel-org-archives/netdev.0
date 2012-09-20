From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next] net: only run neigh_forced_gc() from one cpu
Date: Thu, 20 Sep 2012 20:22:50 +0900
Message-ID: <CAKD1Yr09PKW6yMXfELNQ+NW6N4PE5t63T2etUA96fcRYzUSYCg@mail.gmail.com>
References: <1348046827.26523.571.camel@edumazet-glaptop> <20120919.134503.2070066674881117065.davem@davemloft.net>
 <CAKD1Yr11twYakD=-Mn8FiB11-xtyOLb-Q6XWmiE3H63SFRbzUw@mail.gmail.com> <20120919.235102.1659819445753338481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, maze@google.com,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:63448 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946Ab2ITLXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 07:23:11 -0400
Received: by obbuo13 with SMTP id uo13so1322195obb.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 04:23:11 -0700 (PDT)
In-Reply-To: <20120919.235102.1659819445753338481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 20, 2012 at 12:51 PM, David Miller <davem@davemloft.net> wrote:
>> If this patch makes IPv6 performance better without affecting IPv4, it's a
>> good idea to apply it anyway, right? IPv6 dst entry garbage collection can
>> potentially cause serious performance issues on any server with a public
>> IPv6 address, and this patch substantially improves the situation.
>
> He's targetting net-next, and I've told him both in previous public
> discussions and in recent private communication that the correct fix
> is to make ipv6 routes use ref-count-less neighbour handling schemes
> like ipv4.

Fair enough. Removing the cache is a better solution - requiring a
separate cache entry for every address you want to send a packet to is
not suited to a world where every user has 2^64 addresses or more. But
if removing the route cache for IPv6 is a large amount of work that
nobody will sign up for, then fixing the symptoms might be better than
nothing.

The performance degradation could become an attack vector. Of course
the people that run IPv6 servers today can maintain their own patches,
but that's sort of suboptimal.

Is there something else that can be done other than moving to
non-refcounted neighbours?
