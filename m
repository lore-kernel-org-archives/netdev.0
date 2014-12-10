From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/4] netdev: introduce new
 NETIF_F_HW_NETFUNC_OFFLOAD feature flag for switch device offloads
Date: Wed, 10 Dec 2014 10:31:50 +0100
Message-ID: <20141210093150.GA1863@nanopsycho.orion>
References: <1418202320-19491-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:43997 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaLJJbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 04:31:53 -0500
Received: by mail-wg0-f52.google.com with SMTP id x12so3038002wgg.11
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 01:31:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1418202320-19491-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 10, 2014 at 10:05:17AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This is a high level feature flag for all switch asic offloads
>
>switch drivers set this flag on switch ports. Logical devices like
>bridge, bonds, vxlans can inherit this flag from their slaves/ports.


Interesting thing is that you are talking about "switch" (mentioned 3
times on 3 lines), yet the name of bit is "NETFUNC_OFFLOAD". I'm sorry,
I might be missing some obvious facts but "netfunc" seems ambiguous
to me.


>
>The patch also adds the flag to NETIF_F_ONE_FOR_ALL, so that it gets
>propagated to the upperdevices (bridges and bonds).
>
>(In case you did not notice, I am trying a new name NETIF_F_HW_NETFUNC_OFFLOAD for the flag ;)
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>---
> include/linux/netdev_features.h |    5 ++++-
> 1 file changed, 4 insertions(+), 1 deletion(-)
>
>diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>index 8e30685..8ab175b 100644
>--- a/include/linux/netdev_features.h
>+++ b/include/linux/netdev_features.h
>@@ -66,6 +66,7 @@ enum {
> 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
> 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
> 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
>+	NETIF_F_HW_NETFUNC_OFFLOAD_BIT,  /* HW switch offload */
> 
> 	/*
> 	 * Add your fresh new feature above and remember to update
>@@ -124,6 +125,7 @@ enum {
> #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
> #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
> #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
>+#define NETIF_F_HW_NETFUNC_OFFLOAD	__NETIF_F(HW_NETFUNC_OFFLOAD)
> 
> /* Features valid for ethtool to change */
> /* = all defined minus driver/device-class-related */
>@@ -159,7 +161,8 @@ enum {
>  */
> #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
> 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
>-				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
>+				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED | \
>+				 NETIF_F_HW_NETFUNC_OFFLOAD)
> /*
>  * If one device doesn't support one of these features, then disable it
>  * for all in netdev_increment_features.
>-- 
>1.7.10.4
>
