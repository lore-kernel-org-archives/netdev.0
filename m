From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/8 v3] net: Checksum offload changes
Date: Tue, 29 Apr 2014 09:17:34 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404290858230.8713@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:41310 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932491AbaD2QRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 12:17:36 -0400
Received: by mail-qa0-f74.google.com with SMTP id j15so23308qaq.3
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 09:17:35 -0700 (PDT)
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
- Add support for RFC6936, UDP/IPv6 zero checksums
- Add architecture support for csum_add and provided implementations
  for x86_64 and Sparc 32 and 64 bit (please test the latter)

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
