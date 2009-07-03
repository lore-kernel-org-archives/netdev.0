From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict verification
Date: Fri, 3 Jul 2009 14:02:34 +0300
Message-ID: <200907031402.34941.denys@visp.net.lb>
References: <200903011344.45814.denys@visp.net.lb> <200907030246.18054.denys@visp.net.lb> <m1ab3mihjv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41668 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbZGCLCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 07:02:50 -0400
In-Reply-To: <m1ab3mihjv.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 03 July 2009 06:14:44 Eric W. Biederman wrote:

Actually problem doesn't worth a broken egg even.
I am not confused. Just i am trying to explain that some feature 
implementation must follow standards somehow, especially because it break 
things. And it breaks. Actual use for proxy_arp in modern world is very small, 
and i think it is used rarely, only for PPP links for remote customers. But 
even in this case it will break things, if this box have default gateway.

1)If Linux have default gateway configured "some other" interface, enabling 
proxy_arp on ethernet interface will break communication for any network that 
is not configured on this Linux interface. It will just give ARP reply for 
all ARP requests.

2)ACD (Address conflict detection) used in DHCP, Mobile IP and etc, and it 
uses gratituous ARP/ARP Announce. 
Proxy ARP used to help route networks. 
Gratituous ARP/ARP Announce packet have no use for routing, it is for ACD and 
ARP cache updating (for clusters). Linux ARP proxy gives answer to such 
packets, which doesn't have use for routing, but breaks ACD (gives false 
positive ip conflict).

Anyway, i ask advice from one of RFC authors. I will forward it here as soon 
as receive it.
