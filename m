From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC][NET-NEXT PATCH 1/7] ixgbe: this patch adds support for DCB to the kernel and ixgbe driver
Date: Fri, 14 Nov 2008 08:14:36 -0800
Message-ID: <9929d2390811140814n123f4c26p6a810806af79540c@mail.gmail.com>
References: <20081108005042.17939.47091.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Alexander Duyck" <alexander.h.duyck@intel.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:46170 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbYKNQOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 11:14:37 -0500
Received: by yw-out-2324.google.com with SMTP id 9so653679ywe.1
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2008 08:14:36 -0800 (PST)
In-Reply-To: <20081108005042.17939.47091.stgit@gitlost.lost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 7, 2008 at 4:51 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> This adds support for Data Center Bridging (DCB) features in the ixgbe driver and adds an rtnetlink interface for configuring DCB to the kernel.  The DCB feature support included are Priority Grouping (PG) - which allows bandwidth guarantees to be allocated to groups to traffic based on the 802.1q priority, and Priority Based Flow Control (PFC) - which introduces a new MAC control PAUSE frame which works at granularity of the 802.1p priority instead of the link (IEEE 802.3x).
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> ---
>
>  drivers/net/ixgbe/Makefile          |    3
>  drivers/net/ixgbe/ixgbe.h           |   24 +
>  drivers/net/ixgbe/ixgbe_dcb.c       |  332 +++++++++++++++++
>  drivers/net/ixgbe/ixgbe_dcb.h       |  157 ++++++++
>  drivers/net/ixgbe/ixgbe_dcb_82598.c |  398 ++++++++++++++++++++
>  drivers/net/ixgbe/ixgbe_dcb_82598.h |   94 +++++
>  drivers/net/ixgbe/ixgbe_dcb_nl.c    |  352 ++++++++++++++++++
>  drivers/net/ixgbe/ixgbe_ethtool.c   |   30 +
>  drivers/net/ixgbe/ixgbe_main.c      |  185 ++++++++-
>  include/linux/dcbnl.h               |  230 +++++++++++
>  include/linux/netdevice.h           |    8
>  include/linux/rtnetlink.h           |    5
>  include/net/dcbnl.h                 |   44 ++
>  net/Kconfig                         |    1
>  net/Makefile                        |    3
>  net/dcb/Kconfig                     |   12 +
>  net/dcb/Makefile                    |    1
>  net/dcb/dcbnl.c                     |  704 +++++++++++++++++++++++++++++++++++
>  18 files changed, 2564 insertions(+), 19 deletions(-)

During testing of this patch, we found an issue where if Data Center
Bridging (DCB) is not enabled in the kernel, ixgbe does not compile
due to dependencies to DCB.  I have an updated patch which wraps all
the DCB code to be dependent on CONFIG_DCBNL, but before posting the
updated patch I wanted to get feedback on the following options:

1) Make all DCB code in the ixgbe driver dependent on CONFIG_DCBNL to
be present to build.
2) Have an IXGBE_CONFIG_DCB build option for ixgbe that becomes
available when CONFIG_DCBNL is present.

I would think that option 2 would be best, so that if users wanted
DCB, but not in ixgbe they could simple not enable DCB in ixgbe.


-- 
Cheers,
Jeff
