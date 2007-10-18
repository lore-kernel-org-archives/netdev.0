From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 9174] New: linux-2.6.23-git11 kernel panic
Date: Thu, 18 Oct 2007 12:58:42 +0200
Message-ID: <47173C62.5080302@trash.net>
References: <bug-9174-10286@http.bugzilla.kernel.org/> <20071017130131.365f9fb6.akpm@linux-foundation.org> <47172D10.2040309@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090002060200030301030806"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: plamen.petrov@tk.ru.acad.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34480 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbXJRK7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 06:59:08 -0400
In-Reply-To: <47172D10.2040309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090002060200030301030806
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Andrew Morton wrote:
>> On Wed, 17 Oct 2007 07:36:16 -0700 (PDT)
>> bugme-daemon@bugzilla.kernel.org wrote:
>>
>>> http://bugzilla.kernel.org/show_bug.cgi?id=9174
>>>
>>>            Summary: linux-2.6.23-git11 kernel panic
>  >>
> 
>>> EIP is at packet_rcv_0x1a2/0x360
> 
> 
> Please find out on which device the packet socket is opened by
> looking at /proc/net/packet and comparing the Iface shown there
> to the ifindexes listed in "ip link list".


Well, he replied in private mail, the device in question is
an IPv6-over-IPv4 tunnel, which doesn't have any header_ops,
so the crash happens in dev_parse_header when dereferencing
them.

Signed-off-by: Patrick McHardy <kaber@trash.net>


--------------090002060200030301030806
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 39dd83b..452c88d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -827,7 +827,7 @@ static inline int dev_parse_header(const struct sk_buff *skb,
 {
 	const struct net_device *dev = skb->dev;
 
-	if (!dev->header_ops->parse)
+	if (!dev->header_ops || !dev->header_ops->parse)
 		return 0;
 	return dev->header_ops->parse(skb, haddr);
 }

--------------090002060200030301030806--
