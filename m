From: Stephen Hemminger <shemminger@vyatta.com>
Subject: TCP MD5 and socket accept
Date: Wed, 25 Jun 2008 22:56:57 -0700
Message-ID: <20080625225657.61e1b29b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50702 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752470AbYFZF46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 01:56:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like the child socket on accept doesn't inherit the MD5 mappings
from the listening socket.  This leads to the situation where the data
after the initial SYN, ACK gets a MD5 mismatch until the child socket
is updated with setsockopt.

My question was this an intentional part of the initial design?

What will break if tcp_create_openreq_child was fixed to copy md5_info if
present?

This all comes about because right now using Quagga a Linux to Linux
works with TCP MD5. But a Linux to Cisco connection fails if using
TCP MD5.
