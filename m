From: Alexander Duyck <aduyck@mirantis.com>
Subject: [RFC PATCH 0/2] Rework of "net: local checksum offload for
 encapsulation"
Date: Mon, 11 Jan 2016 09:05:59 -0800
Message-ID: <20160111165937.5210.61555.stgit@localhost.localdomain>
References: <568E9BF9.2050001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, alexander.duyck@gmail.com
To: ecree@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36838 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933658AbcAKRGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 12:06:01 -0500
Received: by mail-pa0-f54.google.com with SMTP id yy13so231417734pab.3
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 09:06:01 -0800 (PST)
In-Reply-To: <568E9BF9.2050001@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Edward,

Attached is your first patch with a couple of modifications in order to
improve performance and enable the use of local checksum offloag for GSO.
The second patch is my UDP local checksum offload patch for UDP tunnel
segmentation offload.

Feel free to incorporate the GSO patch into your series if you want, or
borrow liberally if you can apply some of this to GRE as I haven't gotten
around to working on that yet as I started doing a clean-up on the Intel
drivers to enable NETIF_F_HW_CSUM for a number of parts.

- Alex

---

Alexander Duyck (1):
      net: Add support for UDP local checksum offload as a part of tunnel segmentation

Edward Cree (1):
      net: local checksum offload for encapsulation


 include/linux/skbuff.h    |   30 ++++++++++++++++++++++++++++++
 net/ipv4/ip_tunnel_core.c |    4 +++-
 net/ipv4/udp.c            |   24 ++++++------------------
 net/ipv4/udp_offload.c    |   38 +++++++++++++++++++++++---------------
 net/ipv6/ip6_checksum.c   |   23 ++++++-----------------
 5 files changed, 68 insertions(+), 51 deletions(-)
