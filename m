From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH WIP RFC 0/3] mpls: support for ler
Date: Wed,  3 Jun 2015 07:21:43 -0700
Message-ID: <1433341306-29288-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com, rshearma@brocade.com, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:34509 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932755AbbFCOVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 10:21:53 -0400
Received: by qcej9 with SMTP id j9so4445648qce.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 07:21:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This is still WIP and incomplete.
Posting it here because of the other discussions
happening around mpls ler in the context of Roberts
code and I happened to mention this implementation.

This was in response to earlier email thread with Eric on
net-next of possibly using xfrm style stacked destination
approach.

I introduce a new set of tunnel ops for light weight
tunnels (lwt), but this could be merged with the
other ip_tunnels code if possible.

I had this code for 3.2 kernel initially, and 
as I was pulling out code, I realize i had to separate
out some other mpls code that i have been working on
and quite likely this will not even compile. Sorry abt
that.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (3):
  lwtunnels: basic infra for light weight tunnels like mpls
  ipv4 fib: lwtunnel handling
  mpls: register lwtunnel ops

 include/linux/if_lwtunnel.h      |    8 ++
 include/net/dst.h                |    2 +
 include/net/ip_fib.h             |    5 +-
 include/net/lwtunnel.h           |   61 +++++++++++++
 include/uapi/linux/if_lwtunnel.h |   12 +++
 include/uapi/linux/rtnetlink.h   |    8 +-
 net/Makefile                     |    2 +-
 net/ipv4/fib_frontend.c          |    6 ++
 net/ipv4/fib_semantics.c         |   34 +++++++-
 net/ipv4/route.c                 |    5 ++
 net/lwtunnel.c                   |  177 ++++++++++++++++++++++++++++++++++++++
 net/mpls/af_mpls.c               |  143 ++++++++++++++++++++++++++++++
 net/mpls/internal.h              |    5 ++
 13 files changed, 464 insertions(+), 4 deletions(-)
 create mode 100644 include/linux/if_lwtunnel.h
 create mode 100644 include/net/lwtunnel.h
 create mode 100644 include/uapi/linux/if_lwtunnel.h
 create mode 100644 net/lwtunnel.c

-- 
1.7.10.4
