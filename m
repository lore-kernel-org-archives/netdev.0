From: Mitchell Erblich <erblichs@earthlink.net>
Subject: Re: PATCH: uninitialized memory access in tcp_parse_options
Date: Mon, 21 Jun 2010 11:02:08 -0700
Message-ID: <3E37AD8C-208F-42B8-AA04-E0B294D909A8@earthlink.net>
References: <1277127249.9469.53.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:57506 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752093Ab0FUSCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 14:02:13 -0400
In-Reply-To: <1277127249.9469.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathieu Lacage,

		The standard default for TCP with IPv4 is 536, which
		translates to 576 MTU.

		Thus, why don't you init mss to 536?

		Mitchell Erblich
		===============

On Jun 21, 2010, at 6:34 AM, Mathieu Lacage wrote:

> valgrind reports the following error:
> 
> ==15996== Conditional jump or move depends on uninitialised value(s)
> ==15996==    at 0x6E63E4C: tcp_parse_options (tcp_input.c:3776)
> ==15996==    by 0x6E856A3: tcp_check_req (tcp_minisocks.c:532)
> ==15996==    by 0x6E7F0C6: tcp_v4_hnd_req (tcp_ipv4.c:1492)
> ==15996==    by 0x6E7F55A: tcp_v4_do_rcv (tcp_ipv4.c:1571)
> ==15996==    by 0x6E808C5: tcp_v4_rcv (tcp_ipv4.c:1690)
> ==15996==    by 0x6E2DA7B: ip_local_deliver_finish (ip_input.c:231)
> ==15996==    by 0x6E2DE0C: ip_local_deliver (netfilter.h:206)
> ==15996==    by 0x6E2E940: ip_rcv_finish (dst.h:255)
> ==15996==    by 0x6E2F17C: ip_rcv (netfilter.h:206)
> ==15996==    by 0x6D53D0E: __netif_receive_skb (dev.c:2873)
> ==15996==    by 0x6D5521F: process_backlog (dev.c:3305)
> ==15996==    by 0x6D55A20: net_rx_action (dev.c:3435)
> 
> The attached patch (generated against net-next-2.6) fixes that error by
> making sure that user_mss is correctly initialized at the start of
> tcp_parse_options, just like saw_tstamp is initialized at the start of
> this function. To try to be coherent, this patch also removes the
> redundant initialization of saw_tstamp from the caller, tcp_check_req.
> 
> hope this helps,
> Mathieu
> -- 
> Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
> Tel: +33 4 9238 5056
> <tcp-options.patch>

