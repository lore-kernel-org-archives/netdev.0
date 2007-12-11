From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 0/7] Make ipv4_devconf (all and default) live in
 net namespaces
Date: Tue, 11 Dec 2007 20:44:09 +0300
Message-ID: <475ECC69.1040809@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38790 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794AbXLKRoZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 12:44:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv4_devconf_(all) and ipv4_devconf_dflt are currently
global, but should be per-namespace.

This set moves them on the struct net. Or, more precisely,
on the struct netns_ipv4, which in turn is on the struct net.

There are two minor things that are to be done additionally
to this set:

 1. The snmp_seq_show() needs the IPV4_DEVCONF_ALL(FORWARDING)
    value, but since this entry is still global no valid struct 
    net can be get in it, so I use the init_net's one. After 
    snmp is made per-namespace, this will be fixed easily.

 2. The rt_fill_info() needs the IPV4_DEVCONF_ALL(MC_FORWARDING),
    but the routing code is not tuned to work inside namespaces
    yet, so I use the init_net in it as well. Denis is currently
    working on ipv4 routing, so this will be prepared shortly.

Happily, all the other places of devconf-s usage can provide a
struct net pointer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
