From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: RE: [PATCH] vmxnet3: remove set_flag_le{16,64} functions
Date: Sat, 16 Oct 2010 08:57:37 -0700
Message-ID: <89E2752CFA8EC044846EB8499819134102BD7E1856@EXCH-MBX-4.vmware.com>
References: <1287214392-8963-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:32348 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752107Ab0JPP5i convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Oct 2010 11:57:38 -0400
In-Reply-To: <1287214392-8963-1-git-send-email-harvey.harrison@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________________
From: Harvey Harrison [harvey.harrison@gmail.com]
Sent: Saturday, October 16, 2010 12:33 AM
To: Shreyas Bhatewara
Cc: netdev@vger.kernel.org; shemminger@vyatta.com
Subject: [PATCH] vmxnet3: remove set_flag_le{16,64} functions

Opencode the flag setting in the few places it was being done.

Signed-off-by: Harvey Harrison harvey.harrison@gmail.com
---
@@ -1617,8 +1599,7 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
                                               VMXNET3_CMD_UPDATE_VLAN_FILTERS);

                        /* update FEATURES to device */
-                       reset_flag_le64(&devRead->misc.uptFeatures,
-                                       UPT1_F_RXVLAN);
+                       devRead->misc.uptFeatures |= cpu_to_le64(UPT1_F_RXVLAN);
                        VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
                                               VMXNET3_CMD_UPDATE_FEATURE);
                }


This hunk is wrong, UPT1_F_RXVLAN should be reset here.

I fail to understand why set/reset functions were not good enough and why this opencoding is required. I agree with your earlier suggestion about replacing two conversions with *data |= cpu_to_le16(flag); though.


Regards.
Shreyas