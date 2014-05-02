From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/8 v4] net: Checksum offload changes
Date: Fri, 2 May 2014 16:27:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405021526150.19170@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:52439 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbaEBXcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 19:32:54 -0400
Received: by mail-qa0-f74.google.com with SMTP id ih12so31680qab.5
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 16:32:53 -0700 (PDT)
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
- Add some for RFC6936, UDP/IPv6 zero checksums
- Add architecture support for csum_add and provide implementations
  for x86_64 and Sparc 32 and 64 bit (please test the latter)

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
