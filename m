From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 68501] New: llc_fixup_skb considers PDU len including
 ETH_HLEN
Date: Tue, 14 Jan 2014 15:01:24 -0800 (PST)
Message-ID: <20140114.150124.1400867442411259232.davem@davemloft.net>
References: <20140110151156.37ae2618@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbaANXBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:01:25 -0500
In-Reply-To: <20140110151156.37ae2618@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 10 Jan 2014 15:11:56 -0800

> In below snip of code in llc_fixup_skb we calculate pdulen from
> eth_hdr(skb)->h_proto which contains total length of packet include ETH_HLEN.
> 
> <snip>
> 119         if (skb->protocol == htons(ETH_P_802_2)) {
> 120                 __be16 pdulen = eth_hdr(skb)->h_proto;
> 121                 s32 data_size = ntohs(pdulen) - llc_len;
> 122 
> 123                 if (data_size < 0 ||
> 124                     !pskb_may_pull(skb, data_size))
> 125                         return 0;
> 
> </snip>
> 
> 
> Line 121 should be changed to 
> 
> 121                 s32 data_size = ntohs(pdulen) - llc_len - ETH_HLEN;

This can't be right, everything I can find says that the length here is:

	the 802.2 packet length - the number of bytes of the 802.2
	(LLC and data) portion of the frame, excluding padding

Which imples that the ethernet header length is not included.
