From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?[PATCH_v8]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Sat, 21 Aug 2010 10:36:48 +0400
Message-ID: <E1OmhhA-0002AU-00.xeb-mail-ru@f220.mail.ru>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from f220.mail.ru ([217.69.128.153]:59528 "EHLO f220.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174Ab0HUGgw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Aug 2010 02:36:52 -0400
Received: from mail by f220.mail.ru with local
	id 1OmhhA-0002AU-00
	for netdev@vger.kernel.org; Sat, 21 Aug 2010 10:36:48 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPP: introduce "pptp" module which implements point-to-point tunneling protocol using pppox framework
NET: introduce the "gre" module for demultiplexing GRE packets on version criteria 
     (required to pptp and ip_gre may coexists)
NET: ip_gre: update to use the "gre" module

Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
---
This patch introduces then pptp support to the linux kernel which dramatically speeds up pptp vpn connections and decreases cpu usage in comparison of existing user-space implementation (poptop/pptpclient). There is accel-pptp project (https://sourceforge.net/projects/accel-pptp/) to utilize this module, it contains plugin for pppd to use pptp in client-mode and modified pptpd (poptop) to build high-performance pptp NAS.

There was many changes from initial submitted patch, most important are:
1. using rcu instead of read-write locks
2. using static bitmap instead of dynamically allocated
3. using vmalloc for memory allocation instead of BITS_PER_LONG + __get_free_pages
4. fixed many coding style issues
Thanks to Eric Dumazet.
