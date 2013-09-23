From: Tom Herbert <therbert@google.com>
Subject: [PATCH 0/2] Toeplitz hashing
Date: Mon, 23 Sep 2013 15:41:45 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1309231534010.23714@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f202.google.com ([209.85.213.202]:64892 "EHLO
	mail-ye0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052Ab3IWWlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 18:41:47 -0400
Received: by mail-ye0-f202.google.com with SMTP id r14so437274yen.1
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 15:41:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches introduce software implementation of Toeplitz hashing.
The first use case is in inet_ehashfn and inet6_ehashfn using Toeplitz
for just IPv4 and IPv6 TCP connection lookup.

In some follow up patches we can move to using the HW hash itself to
do connection lookup (possibly eliminating SW hash computation on RX.
These will do:
  1) Convert skb_get_rxhash (used for RPS steering) to use Toeplitz. 
  2) Allow TCP connection lookup to use rxhash if the hash if the
     hash is marked as being proper Toeplitz hash.
  3) Allow drivers to mark a hash value as being proper Toeplitz
     of a TCP packet

There's also the possibility of calculating the Toeplitz hash for a
connection in order to deduce which RSS queue the connection maps
to, and thus allow a poor man's aRFS (idea from Jesse Brandeburg).
