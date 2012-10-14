From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 23:07:38 +0200
Message-ID: <1350248858.21172.17197.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:62422 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab2JNVHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 17:07:42 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1007328eaa.19
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 14:07:41 -0700 (PDT)
In-Reply-To: <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-14 at 22:39 +0200, Jan Hinnerk Stosch wrote:

> ntpd    368  ntp   16u     IPv4              10453      0t0    UDP *:ntp
> ntpd    368  ntp   17u     IPv6              10454      0t0    UDP *:ntp
> ntpd    368  ntp   18u     IPv4              10460      0t0    UDP
> localhost.localdomain:ntp
> ntpd    368  ntp   19u     IPv4              10461      0t0    UDP
> hinniepc.fritz.box:ntp
> ntpd    368  ntp   20u     IPv6               8775      0t0    UDP
> [fe80::922b:34ff:fe33:c292]:ntp
> ntpd    368  ntp   21u  netlink                         0t0  10463 ROUTE

Hmm, your ntpd doesnt listen normally to ::1 UDP 123

grep ntpd /var/log/syslog :

(Here I have : )

ntpd[4912]: ntpd 4.2.6p3@1.2290-o Mon Aug 20 15:15:21 UTC 2012 (1)
ntpd[4913]: proto: precision = 0.980 usec
ntpd[4913]: ntp_io: estimated max descriptors: 1024, initial socket
boundary: 16
ntpd[4913]: Listen and drop on 0 v4wildcard 0.0.0.0 UDP 123
ntpd[4913]: Listen and drop on 1 v6wildcard :: UDP 123
ntpd[4913]: Listen normally on 2 lo 127.0.0.1 UDP 123
ntpd[4913]: Listen normally on 3 eth1 172.30.42.8 UDP 123
ntpd[4913]: Listen normally on 4 lo ::1 UDP 123
ntpd[4913]: Listen normally on 5 eth1 fe80::222:15ff:fe87:3ff6 UDP 123
ntpd[4913]: peers refreshed
ntpd[4913]: Listening on routing socket on fd #22 for interface updates
