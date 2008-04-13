From: Kostya B <bkostya@hotmail.com>
Subject: UFO csum - udp4_hwcsum_outgoing
Date: Sun, 13 Apr 2008 14:41:39 +0000
Message-ID: <BAY121-W330A647FE33FFA81C4F7DFB6E90@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"
Content-Transfer-Encoding: 8bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s22.bay0.hotmail.com ([65.54.246.94]:12330 "EHLO
	bay0-omc1-s22.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752286AbYDMOlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 10:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
Suppose a network driver with both TSO and UFO support (2.6.22.18). 
Normally on Tx, all outgoing skb are checksummed as PARTIAL. However, the udp4_hwcsum_outgoing() could change it to be CHECKSUM_NONE.

In that case such skb  becomes netif_needs_gso() and wrongly ask for software gso:

	return skb_is_gso(skb) &&
	       (!skb_gso_ok(skb, dev->features) ||
		unlikely(skb->ip_summed != CHECKSUM_PARTIAL));


Is that intentional? It looks quite weird, because UFO drivers declare NETIF_F_HW_CSUM.
Furthermore it treated by __software__  skb_gso_segment() and fails on 

BUG_ON(skb_shinfo(skb)->frag_list); 

Please advice.

- Kostya


_________________________________________________________________
Explore the seven wonders of the world
http://search.msn.com/results.aspx?q=7+wonders+world&mkt=en-US&form=QBRE
