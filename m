From: Alexey Dobriyan <adobriyan@openvz.org>
Subject: igmp: possible NULL dereference after GFP_ATOMIC allocation?
Date: Tue, 30 Jan 2007 13:57:01 +0300
Message-ID: <20070130105701.GA6015@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, dlstevens@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:16289 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034AbXA3KwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 05:52:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

igmpv3_newpack() uses alloc_skb() with GFP_ATOMIC.
It fails, igmpv3_newpack() returns NULL.
add_grhead(), sees NULL,  returns NULL.

At one place add_grhead() return value fed into skb_put() which
dereferences it.

net/ipv4/igmp.c:
   454			if (first) {
   455				skb = add_grhead(skb, pmc, type, &pgr);
   456				first = 0;
   457			}
   458			psrc = (u32 *)skb_put(skb, sizeof(u32));

