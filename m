From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v3 0/5]: ixgbevf: Allow querying VFs RSS indirection
 table and key
Date: Mon, 05 Jan 2015 16:47:51 +0200
Message-ID: <54AAA417.2060201@cloudius-systems.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:34260 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463AbbAEOrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 09:47:55 -0500
Received: by mail-we0-f169.google.com with SMTP id m14so7998482wev.14
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 06:47:54 -0800 (PST)
In-Reply-To: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/05/15 16:15, Vlad Zolotarov wrote:
> Add the ethtool ops to VF driver to allow querying the RSS indirection table
> and RSS Random Key.
>
>   - PF driver: Add new VF-PF channel commands.
>   - VF driver: Utilize these new commands and add the corresponding
>                ethtool callbacks.

Oops - forgot to run checkpatch before sending and there were some 
issues with styling... ;)
Have just sent v4 with all styling issues fixed... ;)

>
> New in v3:
>     - Added a missing support for x550 devices.
>     - Mask the indirection table values according to PSRTYPE[n].RQPL.
>     - Minimized the number of added VF-PF commands.
>
> New in v2:
>     - Added a detailed description to patches 4 and 5.
>
> New in v1 (compared to RFC):
>     - Use "if-else" statement instead of a "switch-case" for a single option case.
>       More specifically: in cases where the newly added API version is the only one
>       allowed. We may consider using a "switch-case" back again when the list of
>       allowed API versions in these specific places grows up.
>
> Vlad Zolotarov (5):
>    ixgbe: Add a RETA query command to VF-PF channel API
>    ixgbevf: Add a RETA query code
>    ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
>    ixgbevf: Add RSS Key query code
>    ixgbevf: Add the appropriate ethtool ops to query RSS indirection
>      table and key
>
>   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  91 +++++++++++++++
>   drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  43 +++++++
>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
>   drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
>   drivers/net/ethernet/intel/ixgbevf/vf.c           | 132 ++++++++++++++++++++++
>   drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
>   7 files changed, 291 insertions(+), 1 deletion(-)
>
