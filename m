From: Arjan van de Ven <arjan@infradead.org>
Subject: sleeping in irq context in match()
Date: Wed, 23 Jul 2008 11:57:06 -0700
Message-ID: <20080723115706.38060204@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45276 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbYGWS5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 14:57:54 -0400
Received: from ip131.fa1-0-1.occ.iinet.com ([198.145.32.131] helo=localhost.localdomain)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1KLjWX-0001zT-Ia
	for netdev@vger.kernel.org; Wed, 23 Jul 2008 18:57:18 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the backtrace below is popping up in kerneloops.org stats pretty
quickly; I don't know if it's been discussed here before but
just wanted to mention it in case it hasn't been..
(it's rank 13 right now, out of nowhere)

http://www.kerneloops.org/searchweek.php?search=match  for more info


__might_sleep
mutex_lock_nested
rtnl_lock
*match
ipt_do_table
ipt_local_in_hook
nf_iterate
nf_hook_slow
ip_local_deliver
ip_rcv_finish
ip_rcv
netif_receive_skb
tg3_poll


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
