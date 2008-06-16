From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 0/8] netns: optimize tcp and udp hashtables wrt net
 namespaces
Date: Mon, 16 Jun 2008 13:35:32 +0400
Message-ID: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35571 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977AbYFPJh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:37:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently hash functions to store udp sockets, bind buckets,
listening and established tcp sockets take only ports and/or
addresses into account.

The result is nasty. Consider processes in different namespaces
communicate to each other or the outer world with same ports 
or addresses (e.g. dns server run in each namespace, apache server
listening a 80 port in each ns or communications via lo). All 
these sockets will all be linked in a single hash chain, thus 
producing too long chains.

To avoid this situation the proposal is to add some "salt" to
hash functions taking the namespace into account.

I made this "salt" disappear for CONFIG_NET_NS=n case.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

