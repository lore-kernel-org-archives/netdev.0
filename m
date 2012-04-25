From: Pradeep Kanyar <pradeep.kanyar@gmail.com>
Subject: Question on IPv6 addresses and netlink message ordering
Date: Wed, 25 Apr 2012 08:41:16 +0530
Message-ID: <CAL7k4TzeJAb8ONJyK1ED3sLbpGeoL6_gBobkphbQvD6YYkhL0Q@mail.gmail.com>
References: <CAL7k4TzFHavRETDo-myeQonR0RyA35v5uwe1NKaxREn3E1xdZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47779 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705Ab2DYDLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 23:11:17 -0400
Received: by wejx9 with SMTP id x9so829397wej.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 20:11:16 -0700 (PDT)
In-Reply-To: <CAL7k4TzFHavRETDo-myeQonR0RyA35v5uwe1NKaxREn3E1xdZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
If we configure a global IPv6 address on an interface in linux, and if
we monitor the netlink messages
[using nl-monitor from libnl for e.g,] I see that we get RTM_NEWROUTE
for the global address subnet
first, and then RTM_NEWADDR. Isn't this strange? Shouldn't we be
seeing RTM_NEWADDR first
andRTM_NEWROUTE subsequently ....? I put some prints in the path and I
see that the following
seems to be order of events [initially at least] when I configure a
global v6 address on an interface:

1. RTM_NEWROUTE notify in fib6_add_rt2node
2. RTM_NEWADDR notify in addrconf_dad_completed

I saw this on a system running 2.6.32 but a cursory look at more
recent kernels seemed to indicate
that the code path hasn't changed much in this area [ but I might be wrong ].

Why is this out-of-order? On the contrary, in case of IPv4 addresses,
we always see RTM_NEWADDR
first followed by RTM_NEWROUTE [for the directly connected network]

Thanks,
Pradeep
