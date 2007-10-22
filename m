From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 0/5] Diet struct net_device a bit
Date: Mon, 22 Oct 2007 16:31:44 +0400
Message-ID: <471C9830.5070407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40965 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184AbXJVMbJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 08:31:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are some pointers, that are used in protocols/drivers/etc
in this struct. E.g. br_port, macvlan_port, ec_ptr, etc. Some of
them can be simply compile out with ifdefs, some require a bit
closer look.

Here's the summary:
Compiled out in this set with appropriate ifdef:
 * br_port
 * macvlan_port
 * dn_ptr
 * ec_ptr
 * ax25_ptr

Require a closer look:
 * atalk_ptr is shared with irda with "should we get our own 
   field?" comment;
 * ip_ptr and
 * ip6_ptr are used in headers and gcc complains when trying
   to compile net/socket.c that these fields are unreclared;
 * ieee80211_ptr is used in many wireless drivers. Need time
   to check for the config dependencies.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
