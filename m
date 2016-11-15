From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v3 0/5] Adding PHY-Tunables and downshift support
Date: Tue, 15 Nov 2016 11:19:59 +0100
Message-ID: <1479205204-27768-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <raju.lakkaraju@microsemi.com>,
        <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0046.outbound.protection.outlook.com ([104.47.42.46]:43584
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755647AbcKOKU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 05:20:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This follow fixes the comments provided on the v2 series.

Following is the list of changes.
- Spelling in "net: phy: Add downshift get/set support in Microsemi PHYs driver"

Ethtool patches will follow shortly.

Old cover letters included below.

Please review.

Best regards
Allan and Raju


Raju Lakkaraju (5):
  ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE and ETHTOOL_PHY_STUNABLE
  ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE
  ethtool: (uapi) Add ETHTOOL_PHY_DOWNSHIFT to PHY tunables
  ethtool: Core impl for ETHTOOL_PHY_DOWNSHIFT tunable
  net: phy: Add downshift get/set support in Microsemi PHYs driver

 drivers/net/phy/mscc.c       | 100 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h          |   7 +++
 include/uapi/linux/ethtool.h |  18 +++++++-
 net/core/ethtool.c           |  93 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 217 insertions(+), 1 deletion(-)

> From 5ca4dac36f45e097b93ae4cfdf35a8922e5d975e Mon Sep 17 00:00:00 2001
> prom: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
> Date: Mon, 14 Nov 2016 10:04:07 +0100
> Subject: [PATCH net-next v2 0/5] Adding PHY-Tunables and downshift support
> 
> Hi,
> 
> This is a follow-up on the patch series posted at Fri, 4 Nov 2016 10:55:25
> +0100 (old cover letter included below).
> 
> The following is changed/added/addressed:
> - Support for __ethtool_get_strings()/phy_tunables is added
> - Using DOWNSHIFT_DEV_DISABLE define instead of '0' when disabling
> - If downshifting clould not be eanbled with the requested count, then a
>   trace message with a hist is printed.
> - Using ERANGE as requested by Andrew.
> - Andrew suggested to use ENOSUPP when a tunable is not implemented We kept
>   the EINVAL because ENOSUPP does not exists, and the existing MAC-level
>   tunable is also using EINVAL in the same scenario.
> - Andrew suggested that the driver should accept a count of 1 and "just"
>   round it up to 2 (the nearest allowed value). We discussed it a bit (Raju
>   and I) and preferred to return EINVAL when a configuration value could
>   not be accommodated. People which wants "help" to choose a supported
>   value should be using the DOWNSHIFT_DEV_DEFAULT_COUNT value.
> - (ethtool) Syntax is changed from "--set-phy-tunable downshift on|off|%d"
>   to "--set-phy-tunable [downshift on|off [count N]]" - as requested by
>   Andrew.
> 
> Ethtool patches will follow shortly.
>
> Old cover letter:
> > From 1a318266822f5d74c58b5219ebbdf5a6a5f567dc Mon Sep 17 00:00:00 2001
> > From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
> > Date: Fri, 4 Nov 2016 10:55:25 +0100
> > Subject: [PATCH net-next 0/5] Adding PHY-Tunables and downshift support
> > 
> > Hi All,
> > 
> > This series add support for PHY tunables, and uses this facility to configure
> > downshifting. The downshifting mechanism is implemented for MSCC phys.
> > 
> > This series tries to address the comments provided back in mid October when this
> > feature was posted along with fast-link-failure. Fast-link-failure has been
> > separated out, but we would like to pick continue on that if/when we agree on
> > how the phy-tunables and downshifting should be done.
> > 
> > The proposed generic interface is similar to ETHTOOL_GTUNABLE/ETHTOOL_STUNABLE,
> > it uses the same type (ethtool_tunable/tunable_type_id) but a new enum
> > (phy_tunable_id) is added to reflect the PHY tunable.
> > 
> > The implementation just call the newly added function pointers in
> > get_tunable/set_tunable phy_device structure.
> > 
> > To configure downshifting, the ethtool_tunable structure is used. 'id' must be
> > set to 'ETHTOOL_PHY_DOWNSHIFT', 'type_id' must be set to 'ETHTOOL_TUNABLE_U8'
> > and 'data' value configure the amount of downshift re-tries.
> > 
> > If configured to DOWNSHIFT_DEV_DISABLE, then downshift is disabled
> > If configured to DOWNSHIFT_DEV_DEFAULT_COUNT, then it is up to the device to
> > choose a device-specific re-try count.
> > 
> > Patches to implement this in ethtool will follow in a few minutes.

-- 
2.7.3
