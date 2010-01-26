From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] IPv6: conntrack: Use protocol-related match
 routine in IPv6 connection track
Date: Mon, 25 Jan 2010 23:35:45 -0800 (PST)
Message-ID: <20100125.233545.219640402.davem@davemloft.net>
References: <4B5E53F4.4020106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, yasuyuki.kozakai@toshiba.co.jp,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750829Ab0AZHfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 02:35:33 -0500
In-Reply-To: <4B5E53F4.4020106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Tue, 26 Jan 2010 10:31:16 +0800

> 
> IPv6 connection track and IPv6 stack separately use a different queue to 
> manage received fragments. So using protocol-related match routine.
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

This problem was also introduced by:

commit 0b5ccb2ee250136dd7385b1c7da28417d0d4d32d
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Dec 15 16:59:18 2009 +0100

    ipv6: reassembly: use seperate reassembly queues for conntrack and local delivery
    
    Currently the same reassembly queue might be used for packets reassembled
    by conntrack in different positions in the stack (PREROUTING/LOCAL_OUT),
    as well as local delivery. This can cause "packet jumps" when the fragment
    completing a reassembled packet is queued from a different position in the
    stack than the previous ones.
    
    Add a "user" identifier to the reassembly queue key to seperate the queues
    of each caller, similar to what we do for IPv4.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

