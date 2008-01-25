From: "Alon Bar-Lev" <alon.barlev@gmail.com>
Subject: iproute2 (addr flush) infinite loop when unprivileged users
Date: Sat, 26 Jan 2008 01:00:34 +0200
Message-ID: <9e0cf0bf0801251500u388b9a5dxda92d6d1e3d86233@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:1034 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760941AbYAYXAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 18:00:36 -0500
Received: by ug-out-1314.google.com with SMTP id z38so595797ugc.16
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 15:00:34 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

When executing the following command using unprivileged users there is
an infinite loop...
/sbin/ip route flush dev eth1

Execution with -s produces:
*** Round 28153, deleting 2 entries ***

*** Round 28154, deleting 2 entries ***

*** Round 28155, deleting 2 entries ***

*** Round 28156, deleting 2 entries ***

*** Round 28157, deleting 2 entries ***

*** Round 28158, deleting 2 entries ***

*** Round 28159, deleting 2 entries ***

I do not fully understand the sequence, but it may be kernel fault, as
it should have returned EPERM for this request stopping the netlink
request.

Anyway... A simple solution is to store the filter.flushed and fail if
it keeps its value during loop iteration at
ip/ipaddress.c::ipaddr_list_or_flush(), but this is only a
workaround...

Please CC as I am not in netdev list.
Thanks!
Alon.
