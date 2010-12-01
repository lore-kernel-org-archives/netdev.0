From: Stephen Hemminger <shemminger@vyatta.com>
Subject: BUG - routes not correctly deleted when address is deleted
Date: Tue, 30 Nov 2010 16:55:39 -0800
Message-ID: <20101130165539.40ce02c1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58129 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab0LAAzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 19:55:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If multiple addresses are assigned to an interface, and
a route is created that uses that address.  The route is not
deleted when the address is deleted.  Linux does cleanup properly
when the last address is deleted; it seems the FIB lacks the callback
to cleanup routes referencing an address.

Simple example:

# modprobe dummy
# ip li set dev dummy0 up
# ip addr add 192.168.74.160/24 dev dummy0
# ip addr add 192.168.18.11/24 dev dummy0
# ip ro add 74.11.49.0/24 via 192.168.74.160

# ip addr del 192.168.74.160/24 dev dummy0
# ip ro show dev dummy0
74.11.49.0/24 via 192.168.74.160 
192.168.18.0/24  proto kernel  scope link  src 192.168.18.11 

Before I go off and either brute force it (add another call back
into fib_hash and fib_trie), is there a better way?

