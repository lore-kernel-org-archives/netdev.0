From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/9 v2] net: Checksum offload changes
Date: Sat, 26 Apr 2014 14:24:23 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261404550.27669@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:32802 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaDZVYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:24:25 -0400
Received: by mail-pd0-f202.google.com with SMTP id w10so6836pde.3
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 14:24:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am working on overhauling RX checksum offload. Goals of this effort
are:

- Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
- Preserve CHECKSUM_COMPLETE through encapsulation layers
- Don't do skb_checksum more than once per packet
- Unify GRO and non-GRO csum verification as much as possible
- Unify the checksum functions (checksum_init)
- Simply code

What is in this first patch set:

- Create a common "checksum_init" function which is called from
  TCPv{4,6} and UDPv{4,6}
- Add some support for RFC6936, UDP/IPv6 zero checksums
- Allow bad device checksum complete to be trusted.
- Add architecture support for csum_add and provided implementations
  for x86_64 and Sparc 32 and 64 bit (please test the latter)

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
