From: "Micah Gruber" <micah.gruber@gmail.com>
Subject: [PATCH] [2.6.22] Remove unneeded pointer idev from addrconf_cleanup() in net/ipv6/addrconf.c
Date: Mon, 9 Jul 2007 11:30:46 +0800
Message-ID: <aaab98560707082030w6521f4e5qf17a01d83d20faf8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:31002 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758635AbXGIDas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 23:30:48 -0400
Received: by py-out-1112.google.com with SMTP id d32so1444402pye
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2007 20:30:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This trivial patch removes the unneeded pointer idev returned from
__in6_dev_get(), which is never used. The check for NULL can be simply
done by if (__in6_dev_get(dev) == NULL).

Signed-off-by: Micah Gruber < micah.gruber@gmail.com>

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4240,7 +4240,6 @@
void __exit addrconf_cleanup(void)
{
        struct net_device *dev;
-       struct inet6_dev *idev;
        struct inet6_ifaddr *ifa;
        int i;

@@ -4258,7 +4257,7 @@
         */

        for_each_netdev(dev) {
-               if ((idev = __in6_dev_get(dev)) == NULL)
+               if (__in6_dev_get(dev) == NULL)
                        continue;
                addrconf_ifdown(dev, 1);
        }
