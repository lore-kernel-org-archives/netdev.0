From: Justin Pettit <jpettit@nicira.com>
Subject: Issue in __vlan_put_tag?
Date: Fri, 12 Oct 2007 16:58:17 -0700
Message-ID: <F1E039CF-14E4-4200-8AF3-EBB62ECC6519@nicira.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dime139.dizinc.com ([66.7.205.111]:20677 "EHLO
	dime139.dizinc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957AbXJMBDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 21:03:36 -0400
Received: from [76.221.187.188] (port=52745 helo=[192.168.1.23])
	by dime139.dizinc.com with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.68)
	(envelope-from <jpettit@nicira.com>)
	id 1IgUOo-0003KI-Hk
	for netdev@vger.kernel.org; Fri, 12 Oct 2007 19:58:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function __vlan_put_tag modifies adds a VLAN tag to an existing  
Ethernet packet.  In the process, the front of the packet is extended  
by four bytes to accommodate the tag.  This function correctly  
adjusts the mac_header offset, but I think this line is problematic:

	skb->network_header -= VLAN_HLEN;

When access to the network header is needed, the value of skb- 
 >network_header is added to skb->head, which should not have changed  
during any of the previous modifications.  I believe the code as it  
exists now will cause the network header to appear to be four bytes  
earlier than it actually is.

--Justin
