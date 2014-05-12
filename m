From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/8] net: Checksum offload changes - Part III
Date: Mon, 12 May 2014 09:57:53 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405120944250.28961@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:34353 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932196AbaELQ5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 12:57:54 -0400
Received: by mail-oa0-f74.google.com with SMTP id m1so1518004oag.1
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 09:57:54 -0700 (PDT)
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

What is in this third patch set:

- Remove sk_no_check from sunrpc (doesn't seem to have any effect)
- Eliminate no_check from protosw. All protocols are using default of
  zero for this
- Split sk_no_check into sk_no_check_tx and sk_no_check_rx
- Make enabling of UDP6 more restrictive and explicit
- Support zero UDP6 checksums in l2tp
- Support zero UDP6 checksums in vxlan
- Add ability in VXLAN to send non-zero checksums

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
