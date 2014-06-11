From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 0/4] net: Checksum offload changes - Part IV
Date: Tue, 10 Jun 2014 18:54:03 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406101848350.5666@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:44620 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbaFKByF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 21:54:05 -0400
Received: by mail-pa0-f74.google.com with SMTP id rd3so203930pab.1
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 18:54:04 -0700 (PDT)
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

What is in this fourth patch set:

- Preserve CHECKSUM_COMPLETE instead of changing it to
  CHECKSUM_UNNECESSARY. This allows correct reuse in validating multiple
  csums in a packet.
- When SW needs to compute the packet checksum, save it as
  CHECKSUM_COMPLETE. Also mark that checksum was compute by SW.
- Add skb_gro_postpull_rcsum to udp and vxlan to make GRO work with
  CHECKSUM_COMPLETE.

v2: Removed patch setting skb_encapsulation when validating checksum
    in tcp_gro_receive

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
