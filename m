From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 0/6] ipv6: Add lockless UDP send path
Date: Sat, 31 Jan 2015 10:40:12 -0500
Message-ID: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Cc: herbert@gondor.apana.org.au, hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f178.google.com ([209.85.216.178]:45780 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbbAaPk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 10:40:26 -0500
Received: by mail-qc0-f178.google.com with SMTP id b13so24835501qcw.9
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 07:40:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces a lockless UDPv6 send path similar to
what Herbert Xu did for IPv4 a while ago.

There are some difference from IPv4.  IPv6 caching for flow
label is a bit different, as well as it requires another cork
cork structure that holds the IPv6 ancillary data.

Please take a look.

Thanks
-vlad

Vladislav Yasevich (5):
  ipv6: pull cork initialization into its own function.
  ipv6: Append sending data to arbitrary queue
  ipv6: introduce ipv6_make_skb
  ipv6: Introduce udpv6_send_skb()
  udpv6: Add lockless sendmsg() support

 include/linux/ipv6.h  |  12 +-
 include/net/ipv6.h    |  19 +++
 net/ipv6/ip6_output.c | 349 +++++++++++++++++++++++++++++++++-----------------
 net/ipv6/udp.c        |  91 ++++++++-----
 4 files changed, 317 insertions(+), 154 deletions(-)

-- 
1.9.3
