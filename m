From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD
 feature flag for switch device offloads
Date: Fri, 5 Dec 2014 13:17:30 +0100
Message-ID: <20141205121730.GK1866@nanopsycho.orion>
References: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com>
 <54819FDA.2030405@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, sfeldma@gmail.com, bcrl@kvack.org,
	tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:34037 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbaLEMRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 07:17:32 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so733450wgh.20
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 04:17:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54819FDA.2030405@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 05, 2014 at 01:06:50PM CET, jhs@mojatatu.com wrote:
>On 12/04/14 21:26, roopa@cumulusnetworks.com wrote:
>>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>>This is a generic high level feature flag for all switch asic features today.
>>
>>switch drivers set this flag on switch ports. Logical devices like
>>bridge, bonds, vxlans can inherit this flag from their slaves/ports.
>>
>>I had to use SWITCH in the name to avoid ambiguity with other feature
>>flags. But, since i have been harping about not calling it 'switch',
>>I am welcome to any suggestions :)
>>
>
>I know  in this use case it is a switch. But please dont use that term
>for things that we are going to use as generic offload descriptors.
>How about just simple: NETIF_F_HW_DEV_OFFLOAD_BIT

What that should tell it stands for? I think we need something more
specific.


>BTW: Didnt you already have a netdev specific offload feature flag?
>
>cheers,
>jamal
>
>>An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
>>in net_device_flags.
>>---
>>  include/linux/netdev_features.h |    2 ++
>>  1 file changed, 2 insertions(+)
>>
>>diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
>>index 8e30685..68db1de 100644
>>--- a/include/linux/netdev_features.h
>>+++ b/include/linux/netdev_features.h
>>@@ -66,6 +66,7 @@ enum {
>>  	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
>>  	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
>>  	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
>>+	NETIF_F_HW_SWITCH_OFFLOAD_BIT,  /* HW switch offload */
>>
>>  	/*
>>  	 * Add your fresh new feature above and remember to update
>>@@ -124,6 +125,7 @@ enum {
>>  #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
>>  #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
>>  #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
>>+#define NETIF_F_HW_SWITCH_OFFLOAD	__NETIF_F(HW_SWITCH_OFFLOAD)
>>
>>  /* Features valid for ethtool to change */
>>  /* = all defined minus driver/device-class-related */
>>
>
