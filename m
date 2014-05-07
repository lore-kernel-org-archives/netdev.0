From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/7] net: Checksum offload changes - Part II
Date: Wed, 7 May 2014 16:51:33 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071642040.858@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:62098 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbaEGXvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:51:35 -0400
Received: by mail-yh0-f74.google.com with SMTP id 29so200643yhl.3
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:51:34 -0700 (PDT)
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

What is in this second patch set:

- Call common inet checksum validation functions in ICMP{4,6},
  GRE{4,6}, and IGMP.
- In UDP, verify checksum before handing off to encap_rcv.
- Remove custom UDP checksum validation code in L2TP.

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
