From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/10]: Improve SA insert/delete performance
Date: Tue, 15 Aug 2006 04:37:18 -0700 (PDT)
Message-ID: <20060815.043718.59464707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63450
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965361AbWHOLhU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 07:37:20 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ Jamal, you saw the first 5 patches already, the rest is new
  stuff. ]

These patches against the net-2.6 GIT tree try to address some
serious IPSEC SA insert/delete performance problems noticed
by Jamal.

1) Use dynamic hash table sizing for the xfrm_state lookup
   tables.

2) Do not walk all policies and flush bundles on xfrm_state
   changes, instead:
   a) On delete, just allow pending references to deleted
      xfrm_state objects to be handled by policy GC and
      xfrm_dst_check() which runs on every use of a cached
      xfrm dst route
   b) On insert, find xfrm_state objects that might alias with
      the one we are about to insert.  For all such aliases,
      update their generation cound which will force
      xfrm_bundle_ok() (and thus xfrm_dst_check) to consider
      the route stale, forcing a relookup.

Patches forthcoming.
