From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bonding: create netlink event when bonding option is changed
Date: Tue, 19 Aug 2014 16:02:12 +0200
Message-ID: <1408456932-10318-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net, nikolay@redhat.com, dingtianhong@huawei.com,
	sfeldma@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:36331 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbaHSOCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 10:02:18 -0400
Received: by mail-la0-f43.google.com with SMTP id gi9so3439895lab.16
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2014 07:02:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace needs to be notified if one changes some option.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_options.c | 2 ++
 include/linux/netdevice.h          | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index dc73463..d8dc17f 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -625,6 +625,8 @@ int __bond_opt_set(struct bonding *bond,
 out:
 	if (ret)
 		bond_opt_error_interpret(bond, opt, ret, val);
+	else
+		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
 
 	return ret;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 967ddcc..44bc4bd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2017,6 +2017,7 @@ struct pcpu_sw_netstats {
 #define NETDEV_CHANGEUPPER	0x0015
 #define NETDEV_RESEND_IGMP	0x0016
 #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
+#define NETDEV_CHANGEINFODATA	0x0018
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
-- 
1.9.3
