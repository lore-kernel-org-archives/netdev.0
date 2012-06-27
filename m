From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] tcp demux used to signal ip_route_input_noref to not cache
 dst
Date: Wed, 27 Jun 2012 09:19:13 +0200
Message-ID: <1340781553.10893.414.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56057 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756367Ab2F0HTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 03:19:16 -0400
Received: by bkcji2 with SMTP id ji2so637624bkc.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 00:19:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case tcp_v{4|6}_early_demux() doesnt find an ESTABLISHED socket, and
SYN flag is set, and an "atomic_t listener_under_synflood" counter is
not 0, we could :

- instruct make ip_rcv_finish() to not cache the input dst into route
cache (if dst is not found in the hash table)

This would make synflood attacks having minimal impact on route cache

(We did this for the output dst of SYN-cookie-ACK messages)
