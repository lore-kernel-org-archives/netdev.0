From: Peter =?UTF-8?B?TsO4cmx1bmQ=?= <pch@ordbogen.com>
Subject: ipv4: add hash-based multipath routing
Date: Sun, 12 Apr 2015 20:54:30 +0200
Message-ID: <20150412205430.6d7fcd30@tyr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ordbogen.com ([86.58.170.13]:38988 "EHLO mail.ordbogen.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739AbbDLTB6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 15:01:58 -0400
Received: from tyr (x1-6-50-3d-e5-df-ec-14.cpe.webspeed.dk [195.41.44.29])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail.ordbogen.com (Postfix) with ESMTPSA id C86C9B302A
	for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 20:54:30 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm working on adding L3/L4 hash-based IPv4 multipath to the kernel,
but I wonder what the best approach for the mainline kernel is.

When the IPv6 multipath code was added, choosing the routing algorithm
by means of compile-time config or sysctl was rejected, so I assume
that we want to revive the RTA_MP_ALGO or a new attribute?

The IPv6 multipath uses L4 balancing - which is fine for IPv6 where
fragmentation does not happend - but in my opinion the safest default
for IPv4 is L3, especially when multipath is used together with anycast=
=2E

My main problem is the existing multipath code which is really old
(linux 2.1.66). From the looks of it, it attempts to be somewhat random=
,
but in reality it is more or less weighted round-robin, and as far as I
can tell it even has an off-by-one error in its handling of the random
value. I think it is wise to support L3, L4, and per-packet
load-balancing, just like the hardware vendors, but must the per-packet
load-balancing be default, or is it okay to change the default
behavior? Also, would a weighted round-robin with a single per-cpu
counter suffice? This would get rid of the spinlock and avoid causing
cache invalidations of the route info with each packet. But it would no=
t
be true round-robin, which would require a per-route-info counter. If
we are promising round-robin it is bad, but if we are simply promising
weighted per-packet load-balancing, it's a different matter.

Regards,
Peter N=C3=B8rlund
