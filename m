From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] tcp: randomize TCP source ports
Date: Thu, 07 Nov 2013 16:54:09 -0800
Message-ID: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:58859 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab3KHAyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:54:14 -0500
Received: by mail-qa0-f53.google.com with SMTP id k4so1149230qaq.12
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 16:54:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP does proper randomization of ports on active connections only if
bind() is used between socket() and connect()

If bind() is not specifically used, kernel performs autobind, and TCP
autobind typically uses a sequential allocation for a given (dst
address, dst port, src address) tuple.

UDP autobind does a randomization, as part of the effort to make DNS
more secure.

TCP autobind uses a global sequential number (called @hint in source
code) with a perturbation done by secure_ipv4_port_ephemeral(),
 so that the 'hint' of the next port is per (saddr, daddr, dport) tuple

This was probably done to maximize port use and avoid hitting timewait
sockets, but I think it should be OK to replace this stuff by a random
selection to have more entropy in the various flow hashing functions,
and in general higher security levels. TCP timestamps are now well
deployed.

Patch would be trivial, but I'd like to get some comments if
you think this idea is wrong.

Thanks !
