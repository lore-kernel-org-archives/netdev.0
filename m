From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 0/6][NETNS]: Make ipv6_devconf (all and default)
 live in net namespaces
Date: Thu, 10 Jan 2008 16:55:12 +0300
Message-ID: <478623C0.7030008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59678 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221AbYAJN4O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 08:56:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ipv6_devconf_(all) and ipv6_devconf_dflt are currently
global, but should be per-namespace.

This set moves them on the struct net. Or, more precisely,
on the struct netns_ipv6, which is already added.

Unfortunately, many code in the ipv6 cannot yet provide a 
correct struct net to get the ipv6_devconf from (e.g. routing 
code), so this part of job is to be done after the appropriate 
parts are virtualized.

However, after this set user can play with the ipv6_devconf 
inside a namespace not affecting the others.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
