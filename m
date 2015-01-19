From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: ipvlan: Initial check-in of the IPVLAN driver.
Date: Mon, 19 Jan 2015 17:40:11 +0300
Message-ID: <20150119144011.GA19086@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45664 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbASOja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 09:39:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Mahesh Bandewar,

The patch 2ad7bf363841: "ipvlan: Initial check-in of the IPVLAN
driver." from Nov 23, 2014, leads to the following static checker
warning:

	drivers/net/ipvlan/ipvlan_core.c:380 ipvlan_process_v6_outbound()
	warn: 'dst' isn't an ERR_PTR

drivers/net/ipvlan/ipvlan_core.c
   378  
   379          dst = ip6_route_output(dev_net(dev), NULL, &fl6);
   380          if (IS_ERR(dst))
   381                  goto err;

The ip6_route_output() function is not documented but it always returns
a valid pointer.  I believe you are supposed to check something like:

		if (dst->error) {
			ret = dst->error;
			goto error;
		}

   382  
   383          skb_dst_drop(skb);
   384          skb_dst_set(skb, dst);

regards,
dan carpenter
