From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPV4] Swap the ifa allocation with the"ipv4_devconf_setall"
 call
Date: Fri, 07 Dec 2007 12:22:57 +0300
Message-ID: <475910F1.1010007@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58786 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751230AbXLGJXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 04:23:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to Herbert, the ipv4_devconf_setall should be called
only when the ifa is added to the device. However, failed 
ifa allocation may bring things into inconsistent state.

Move the call to ipv4_devconf_setall after the ifa allocation.

Fits both net-2.6 (with offsets) and net-2.6.25 (cleanly).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 0b5f042..1c3e20c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -519,8 +519,6 @@ static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	ipv4_devconf_setall(in_dev);
-
 	ifa = inet_alloc_ifa();
 	if (ifa == NULL) {
 		/*
@@ -531,6 +529,7 @@ static struct in_ifaddr *rtm_to_ifaddr(struct nlmsghdr *nlh)
 		goto errout;
 	}
 
+	ipv4_devconf_setall(in_dev);
 	in_dev_hold(in_dev);
 
 	if (tb[IFA_ADDRESS] == NULL)
