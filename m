From: Patrick McHardy <kaber@trash.net>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 18:33:15 +0200
Message-ID: <469F924B.2090901@trash.net>
References: <123837.78916.qm@web56604.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: andrei radulescu-banu <iubica2@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38161 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765749AbXGSQeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 12:34:13 -0400
In-Reply-To: <123837.78916.qm@web56604.mail.re3.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

andrei radulescu-banu wrote:
> The consensus seems to be that skb's need to carry vlan accelerated tags in their cb's, on rx as well as tx. VLAN_TX_SKB_CB() is perfect for that.


No its not. Its only legal to use while something has ownership
of the skb. Between VLAN devices and real devices qdiscs are
free to use it.

>>[Patrick] On the TX path, it could simply use the CB, but this is actually
> 
> also wrong (for both macvlan and real devices) since qdiscs have
> ownership of the skb in between, and at least netem *does* modify
> the CB, breaking VLAN.
> 
> Thanks for pointing that out... It appears to me that qdisc/netem already breaks the vlan implementation, in the path 
> 
> vlan_dev_hwaccel_hard_start_xmit(): sets accelerated vlan tag in skb->cb, calls
> dev_queue_xmit(): may pass skb to qdisc/netem, which may mangle skb->cb before calling
> dev->hard_start_xmit(), resulting in a tx frame without its vlan tag.
> 
> So netem needs to look for hw accelerated vlan metadata and insert it in the skb... Don't see any other way around this. 


No, we might want to put other data in the cb in the future.
VLAN should follow the rules instead.
