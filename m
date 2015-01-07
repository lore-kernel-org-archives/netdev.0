From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH net-next v5 0/7]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Wed, 7 Jan 2015 11:46:17 -0800
Message-ID: <CALgkqUpBKzVA=WQzz_kVEq69yZkTcYb01PNNBjG3mQ=Q3QPpFQ@mail.gmail.com>
References: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Gleb Natapov <gleb@cloudius-systems.com>,
	Avi Kivity <avi@cloudius-systems.com>,
	jeffrey.t.kirsher@intel.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35885 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbbAGTqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 14:46:17 -0500
Received: by mail-ob0-f173.google.com with SMTP id uy5so4831776obc.4
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 11:46:17 -0800 (PST)
In-Reply-To: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 11:26 AM, Vlad Zolotarov
<vladz@cloudius-systems.com> wrote:
> Add the ethtool ops to VF driver to allow querying the RSS indirection table
> and RSS Random Key.
>
> On some devices VFs share the RSS Redirection Table and Hash Key with a PF and letting
> the VF query this information may introduce some security risks. Therefore we disable this
> feature by default for such devices (e.g. 82599) and allow it for those where there isn't any
> possible risk (e.g. on x550). The new netdev op is going to allow a system administrator to
> change the default behaviour with "ip link set" command.
>
>  - netdev: Add a new netdev op to allow/block VF from querying RSS Indirection Table and
>    RSS Hash Key.
>  - PF driver: Add new VF-PF channel commands.
>  - VF driver: Utilize these new commands and add the corresponding
>               ethtool callbacks.
>
> New in v5:
>    - Added a new netdev op to allow/block VF from querying RSS Indirection Table and
>      RSS Hash Key.
>    - Let VF query the RSS info only if VF is allowed to.
>
> New in v4:
>    - Forgot to run checkpatch on v3 and there were a few styling things to fix. ;)
>
> New in v3:
>    - Added a missing support for x550 devices.
>    - Mask the indirection table values according to PSRTYPE[n].RQPL.
>    - Minimized the number of added VF-PF commands.
>
> New in v2:
>    - Added a detailed description to patches 4 and 5.
>
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single option case.
>      More specifically: in cases where the newly added API version is the only one
>      allowed. We may consider using a "switch-case" back again when the list of
>      allowed API versions in these specific places grows up.
>
> Vlad Zolotarov (7):
>   if_link: Add an additional parameter to ifla_vf_info for RSS querying
>   ixgbe: Add a new netdev op to allow/prevent a VF from querying an RSS
>     info
>   ixgbe: Add a RETA query command to VF-PF channel API
>   ixgbevf: Add a RETA query code
>   ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
>   ixgbevf: Add RSS Key query code
>   ixgbevf: Add the appropriate ethtool ops to query RSS indirection
>     table and key
>
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   7 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 119 +++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   2 +
>  drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  42 +++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 132 ++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
>  include/linux/if_link.h                           |   1 +
>  include/linux/netdevice.h                         |   8 ++
>  include/uapi/linux/if_link.h                      |   8 ++
>  net/core/rtnetlink.c                              |  33 +++++-
>  14 files changed, 372 insertions(+), 7 deletions(-)

The series looks good to me with the addition of the ability to set
policy via the new netdev op.

Thanks Vlad!

Acked-By: Greg Rose <gregory.v.rose@intel.com>

- Greg

>
> --
> 2.1.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
