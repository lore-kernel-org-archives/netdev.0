From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Mon, 29 Jun 2009 09:49:44 +0900
Message-ID: <4A480FA8.4000401@miraclelinux.com>
References: <4A41961B.2090206@miraclelinux.com> <4A4257B8.2090105@hp.com> <1245862760.12000.507.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:46427 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbZF2Atn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 20:49:43 -0400
In-Reply-To: <1245862760.12000.507.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael

Thank you for your comment.

I tried to create a patch of bnx2x driver.
It's the same fix as bnx2 driver.
Could you please check the my patch ?

Of cource, I made sure of compile.

Best Regards,
Naohiro Ooiwa


Signed-off-by: Naohiro Ooiwa <nooiwa@miraclelinux.com>
---
 drivers/net/bnx2x_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index fbf1352..951714a 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8637,6 +8637,14 @@ static int bnx2x_nway_reset(struct net_device *dev)
 	return 0;
 }

+static u32
+bnx2x_get_link(struct net_device *dev)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+
+	return bp->link_vars.link_up;
+}
+
 static int bnx2x_get_eeprom_len(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
@@ -10034,7 +10042,7 @@ static struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_msglevel		= bnx2x_get_msglevel,
 	.set_msglevel		= bnx2x_set_msglevel,
 	.nway_reset		= bnx2x_nway_reset,
-	.get_link		= ethtool_op_get_link,
+	.get_link		= bnx2x_get_link,
 	.get_eeprom_len		= bnx2x_get_eeprom_len,
 	.get_eeprom		= bnx2x_get_eeprom,
 	.set_eeprom		= bnx2x_set_eeprom,
-- 
1.5.4.1

Michael Chan wrote:
> On Wed, 2009-06-24 at 09:43 -0700, Rick Jones wrote:
>> Naohiro Ooiwa wrote:
>>> Hi Michael
>>>
>>> I found a little bug.
>>>
>>> When configure in ifcfg-eth* is ONBOOT=no,
>>> the behavior of ethtool command is wrong.
>>>
>>>     # grep ONBOOT /etc/sysconfig/network-scripts/ifcfg-eth2
>>>     ONBOOT=no
>>>     # ethtool eth2 | tail -n1
>>>             Link detected: yes
>>>
>>> I think "Link detected" should be "no".
>> Why?  Sure, there is no IP on the link, but does that mean the link is 
>> otherwise unusable?  Is ethtool only about IP status?
>>
> 
> Once the device is closed, we no longer keep track of the link state and
> no longer have register access to determine the link state.  So we
> assume it is down.  In reality, it may still be up if WoL is enabled or
> management firmware is running, but the driver can no longer keep track
> of it.  If we have to assume one or the other, I think it is more
> correct to assume it is down.
> 
> 
> 


