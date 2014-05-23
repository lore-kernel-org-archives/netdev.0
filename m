From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/5 v3] net: Checksum offload changes - Part III
Date: Fri, 23 May 2014 08:46:42 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405230840270.11967@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:52022 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbaEWPqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 11:46:44 -0400
Received: by mail-qc0-f201.google.com with SMTP id l6so881392qcy.4
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 08:46:43 -0700 (PDT)
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

V2: Took out vxlan changes to set zero csums in IPv6, this will
    be in a later patch set.
V3: Fixed bug in restricting UDP6 checksums.

Please review carefully and test if possible, mucking with basic
checksum functions is always a little precarious :-)
