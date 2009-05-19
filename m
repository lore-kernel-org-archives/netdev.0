From: David Miller <davem@davemloft.net>
Subject: PIM-SM namespace changes
Date: Mon, 18 May 2009 22:24:29 -0700 (PDT)
Message-ID: <20090518.222429.135907168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35816
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754487AbZESFYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 01:24:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some bugs to fix before I can apply these Tom.

For one thing, in the IPV4 patch:

 	setup_timer(&ipmr_expire_timer, ipmr_expire_process, 0);
 	err = register_netdevice_notifier(&ip_mr_notifier);
+#ifdef CONFIG_IP_PIMSM_V2
+	if (inet_add_protocol(&pim_protocol, IPPROTO_PIM) < 0) {
+		printk(KERN_ERR "ip_mr_init: can't add PIM protocol\n");
+		err = -EAGAIN;
+	}
+#endif
 	if (err)
 		goto reg_notif_fail;

This adds the protocol even if the notifier registry fails.

It also leaves the notifier registered if the protocol add fails.

Also we need to seriously discuss how now we unconditionally
register the PIM protocols.  Before we had a policy of only
doing so conditionally, and that's a change that needs to
be carefully considered and discussed.
