From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/5] net: Checksum offload changes - Part V
Date: Fri, 20 Jun 2014 16:37:28 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406201629550.12225@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:56787 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbaFTXha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 19:37:30 -0400
Received: by mail-oa0-f74.google.com with SMTP id i7so1103509oag.5
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 16:37:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am working on overhauling RX checksum offload. Goals of this effort
are:

- Specify what exactly it means when driver returns CHECKSUM_UNNECESSARY
- Preserve CHECKSUM_COMPLETE through encapsulation layers
- Don't do skb_checksum more than once per packet
- Unify GRO and non-GRO csum verification as much as possible
- Unify the checksum functions (checksum_init)
- Simplify code

What is in this fifth patch set:

- Added GRO checksum validation functions
- Call the GRO validations functions from TCP and GRE gro_receive
- Perform checksum verification in the UDP gro_receive path using
  GRO functions and add support for gro_receive in UDP6

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
