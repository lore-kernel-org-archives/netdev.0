From: Andy Gospodarek <andrew.gospodarek@broadcom.com>
Subject: Re: [RFC 1/3] devlink: Add config parameter get/set operations
Date: Thu, 12 Oct 2017 14:12:48 -0400
Message-ID: <20171012181248.GA66136@C02RW35GFVH8.dhcp.broadcom.net>
References: <1507815262-33294-1-git-send-email-steven.lin1@broadcom.com>
 <1507815262-33294-2-git-send-email-steven.lin1@broadcom.com>
 <20171012140317.GC14672@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Lin <steven.lin1@broadcom.com>, netdev@vger.kernel.org,
        jiri@mellanox.com, davem@davemloft.net, michael.chan@broadcom.com,
        linux-pci@vger.kernel.org, linville@tuxdriver.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:49930 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752345AbdJLSM6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 14:12:58 -0400
Received: by mail-qk0-f181.google.com with SMTP id s14so2224538qks.6
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 11:12:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171012140317.GC14672@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 04:03:17PM +0200, Jiri Pirko wrote:
> Thu, Oct 12, 2017 at 03:34:20PM CEST, steven.lin1@broadcom.com wrote:
> >Add support for config parameter get/set commands. Initially used by
> >bnxt driver, but other drivers can use the same, or new, attributes.
> >The config_get() and config_set() operations operate as expected, but
> >note that the driver implementation of the config_set() operation can
> >indicate whether a restart is necessary for the setting to take
> >effect.
> >
> 
> First of all, I like this approach.
> 
> I would like to see this patch split into:
> 1) config-options infrastructure introduction
> 2) specific config options introductions - would be best to have it
>    per-option. We need to make sure every option is very well described
>    and explained usecases. This is needed in order vendors to share
>    attributes among drivers.
> 
> More nits inlined.
> 
> 
> >Signed-off-by: Steve Lin <steven.lin1@broadcom.com>
> >Acked-by: Andy Gospodarek <gospo@broadcom.com>
> >---
> > include/net/devlink.h        |   4 +
> > include/uapi/linux/devlink.h | 108 ++++++++++++++++++++++
> > net/core/devlink.c           | 207 +++++++++++++++++++++++++++++++++++++++++++
> > 3 files changed, 319 insertions(+)
> >
> > static inline void *devlink_priv(struct devlink *devlink)
> >diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
> >index 0cbca96..e959716 100644
> >--- a/include/uapi/linux/devlink.h
> >+++ b/include/uapi/linux/devlink.h
[...]
> >@@ -202,6 +267,49 @@ enum devlink_attr {
> > 
> > 	DEVLINK_ATTR_ESWITCH_ENCAP_MODE,	/* u8 */
> > 
> >+	/* Configuration Parameters */
> >+	DEVLINK_ATTR_SRIOV_ENABLED,		/* u8 */
> >+	DEVLINK_ATTR_NUM_VF_PER_PF,		/* u32 */
> >+	DEVLINK_ATTR_MAX_NUM_PF_MSIX_VECT,	/* u32 */
> >+	DEVLINK_ATTR_MSIX_VECTORS_PER_VF,	/* u32 */
> >+	DEVLINK_ATTR_NPAR_NUM_PARTITIONS_PER_PORT,	/* u32 */
> >+	DEVLINK_ATTR_NPAR_BW_IN_PERCENT,	/* u8 */
> >+	DEVLINK_ATTR_NPAR_BW_RESERVATION,	/* u8 */
> >+	DEVLINK_ATTR_NPAR_BW_RESERVATION_VALID,	/* u8 */
> >+	DEVLINK_ATTR_NPAR_BW_LIMIT,		/* u8 */
> >+	DEVLINK_ATTR_NPAR_BW_LIMIT_VALID,	/* u8 */
> >+	DEVLINK_ATTR_DCBX_MODE,			/* u8 */
> >+	DEVLINK_ATTR_RDMA_ENABLED,		/* u8 */
> >+	DEVLINK_ATTR_MULTIFUNC_MODE,		/* u8 */
> >+	DEVLINK_ATTR_SECURE_NIC_ENABLED,	/* u8 */
> >+	DEVLINK_ATTR_IGNORE_ARI_CAPABILITY,	/* u8 */
> >+	DEVLINK_ATTR_LLDP_NEAREST_BRIDGE_ENABLED,	/* u8 */
> >+	DEVLINK_ATTR_LLDP_NEAREST_NONTPMR_BRIDGE_ENABLED,	/* u8 */
> >+	DEVLINK_ATTR_PME_CAPABILITY_ENABLED,	/* u8 */
> >+	DEVLINK_ATTR_MAGIC_PACKET_WOL_ENABLED,	/* u8 */
> >+	DEVLINK_ATTR_EEE_PWR_SAVE_ENABLED,	/* u8 */
> >+	DEVLINK_ATTR_AUTONEG_PROTOCOL,		/* u8 */
> >+	DEVLINK_ATTR_MEDIA_AUTO_DETECT,		/* u8 */
> >+	DEVLINK_ATTR_PHY_SELECT,		/* u8 */
> >+	DEVLINK_ATTR_PRE_OS_LINK_SPEED_D0,	/* u8 */
> >+	DEVLINK_ATTR_PRE_OS_LINK_SPEED_D3,	/* u8 */
> >+	DEVLINK_ATTR_MBA_ENABLED,		/* u8 */
> >+	DEVLINK_ATTR_MBA_BOOT_TYPE,		/* u8 */
> >+	DEVLINK_ATTR_MBA_DELAY_TIME,		/* u32 */
> >+	DEVLINK_ATTR_MBA_SETUP_HOT_KEY,		/* u8 */
> >+	DEVLINK_ATTR_MBA_HIDE_SETUP_PROMPT,	/* u8 */
> >+	DEVLINK_ATTR_MBA_BOOT_RETRY_COUNT,	/* u32 */
> >+	DEVLINK_ATTR_MBA_VLAN_ENABLED,		/* u8 */
> >+	DEVLINK_ATTR_MBA_VLAN_TAG,		/* u16 */
> >+	DEVLINK_ATTR_MBA_BOOT_PROTOCOL,		/* u8 */
> >+	DEVLINK_ATTR_MBA_LINK_SPEED,		/* u8 */
> 
> Okay, I think it is about the time we should start thinking about
> putting this new config attributes under nester attribute. What do you
> think?
> 

Steve and I actually had a similar discussion yesterday when I was doing
a final review of the patches.

My only objection to nesting was coming up with a way to describe these
functions that made them seem different than existing configuration
options.  In this case of the hardware we are trying to support these
are all permanent config options, so we would call them
DEVLINK_ATTR_NVRAM or DEVLINK_ATTR_PERM.  Does that seem reasonable to
others?
