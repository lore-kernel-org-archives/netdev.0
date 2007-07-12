From: Pavel Emelianov <xemul@openvz.org>
Subject: [PATCH 0/2] Virtual ethernet device (v3)
Date: Thu, 12 Jul 2007 13:13:35 +0400
Message-ID: <4695F0BF.1000305@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:43259 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761254AbXGLJNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 05:13:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Veth stands for Virtual ETHernet. It is a simple tunnel driver
that works at the link layer and looks like a pair of ethernet
devices interconnected with each other.

Mainly it allows to communicate between network namespaces but
it can be used as is as well.

Eric recently sent a similar driver called etun with the sysfs
interface. This implementation uses another interface - the 
RTM_NRELINK message introduced by Patric.

The newlink callback is organized that way to make it easy to 
create the peer device in the separate namespace when we have 
them in kernel.

Changes from v.2.1:
 * Made the generic routine for link creation to be used
   by veth driver, any other tunnel driver that needs to
   create several devices at once and rtnl_newlink() code.

Changes from v.2:
 * Rebase over latest netdev tree. No actual changes;
 * Small code rework.

Changes from v.1:
 * percpu statistics;
 * standard convention for nla policy names;
 * module alias added;
 * xmit function fixes noticed by Patric;
 * code cleanup.

The patch for an ip utility is also provided.

Signed-off-by: Pavel Emelianov <xemul@openvz.org>
Cc: Patrick McHardy <kaber@trash.net>
