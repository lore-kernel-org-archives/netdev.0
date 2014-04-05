From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/6] net: Checksum offload changes, part I
Date: Fri, 4 Apr 2014 17:26:11 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404041712190.20457@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:49577 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229AbaDEA0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 20:26:12 -0400
Received: by mail-ob0-f201.google.com with SMTP id gq1so724968obb.2
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 17:26:12 -0700 (PDT)
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

- Added net/core/checksum.c
- Create a common "checksum_init" function which is called from
  TCPv{4,6} and UDPv{4,6}
- Add some support for RFC6936, UDP/IPv6 zero checksums

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
