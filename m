From: Paul Marks <pmarks@google.com>
Subject: Question about locking in ndisc.c
Date: Tue, 4 Dec 2012 12:52:08 -0800
Message-ID: <CAHaKRvJtBhKUsUe_uBCd+gVhBz3PWmAqbXLSzc6=L4A9URoLYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:35102 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527Ab2LDUw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 15:52:29 -0500
Received: by mail-qc0-f174.google.com with SMTP id o22so2341846qcr.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 12:52:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been reading through net/ipv6/ndisc.c recently (trying to
determine if it'd be feasible to implement RFC6724 Rule 5.5), and I'm
confused by the lack of visible locking in the
ndisc_router_discovery() function.

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=net/ipv6/ndisc.c;h=2edce30ef7338cdf1916eef98b353c7dbbc7bcda;hb=HEAD#l1048

There are values written all over the place, for example:
- in6_dev->if_flags
- neigh->flags
- rt->rt6i_flags
- in6_dev->nd_parms->...
- in6_dev->tstamp

But I've looked through ndisc.c and icmp.c, and I can't find anything
that would protect this data from concurrent access.  Is there
something I'm missing?
