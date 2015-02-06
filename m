From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v5 0/7]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Thu, 5 Feb 2015 22:52:42 -0800
Message-ID: <CAL3LdT4udpCqSrh8=9zeSQLF_hB9fj-Ocwc3Yxf1Nk64U09BrQ@mail.gmail.com>
References: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
	<1420661025.2491.73.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Gleb Natapov <gleb@cloudius-systems.com>,
	Avi Kivity <avi@cloudius-systems.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:52566 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755095AbbBFGwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 01:52:43 -0500
Received: by mail-ob0-f169.google.com with SMTP id wp4so11608417obc.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 22:52:42 -0800 (PST)
In-Reply-To: <1420661025.2491.73.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 12:03 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> On Wed, 2015-01-07 at 21:26 +0200, Vlad Zolotarov wrote:
>> Add the ethtool ops to VF driver to allow querying the RSS indirection
>> table
>> and RSS Random Key.
>>
>> On some devices VFs share the RSS Redirection Table and Hash Key with
>> a PF and letting
>> the VF query this information may introduce some security risks.
>> Therefore we disable this
>> feature by default for such devices (e.g. 82599) and allow it for
>> those where there isn't any
>> possible risk (e.g. on x550). The new netdev op is going to allow a
>> system administrator to
>> change the default behaviour with "ip link set" command.
>>
>>  - netdev: Add a new netdev op to allow/block VF from querying RSS
>> Indirection Table and
>>    RSS Hash Key.
>>  - PF driver: Add new VF-PF channel commands.
>>  - VF driver: Utilize these new commands and add the corresponding
>>               ethtool callbacks.
>>
>> New in v5:
>>    - Added a new netdev op to allow/block VF from querying RSS
>> Indirection Table and
>>      RSS Hash Key.
>>    - Let VF query the RSS info only if VF is allowed to.
>>
>> New in v4:
>>    - Forgot to run checkpatch on v3 and there were a few styling
>> things to fix. ;)
>>
>> New in v3:
>>    - Added a missing support for x550 devices.
>>    - Mask the indirection table values according to PSRTYPE[n].RQPL.
>>    - Minimized the number of added VF-PF commands.
>>
>> New in v2:
>>    - Added a detailed description to patches 4 and 5.
>>
>> New in v1 (compared to RFC):
>>    - Use "if-else" statement instead of a "switch-case" for a single
>> option case.
>>      More specifically: in cases where the newly added API version is
>> the only one
>>      allowed. We may consider using a "switch-case" back again when
>> the list of
>>      allowed API versions in these specific places grows up.
>>
>> Vlad Zolotarov (7):
>>   if_link: Add an additional parameter to ifla_vf_info for RSS
>> querying
>>   ixgbe: Add a new netdev op to allow/prevent a VF from querying an
>> RSS
>>     info
>>   ixgbe: Add a RETA query command to VF-PF channel API
>>   ixgbevf: Add a RETA query code
>>   ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
>>   ixgbevf: Add RSS Key query code
>>   ixgbevf: Add the appropriate ethtool ops to query RSS indirection
>>     table and key
>>
>>  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 +
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   7 ++
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 119
>> +++++++++++++++++++
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   2 +
>>  drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  42 +++++++
>>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
>>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
>>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 132
>> ++++++++++++++++++++++
>>  drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
>>  include/linux/if_link.h                           |   1 +
>>  include/linux/netdevice.h                         |   8 ++
>>  include/uapi/linux/if_link.h                      |   8 ++
>>  net/core/rtnetlink.c                              |  33 +++++-
>>  14 files changed, 372 insertions(+), 7 deletions(-)
>
> Thanks Vlad, I will add your patches to my queue.

Validation ran into issues with your patch series, they reported the following:
Ethtool has "Cannot get RX ring count: Operation not supported" errors
when trying to access RSS flow hash table.

So I am dropping the series for now and will await a v6.

-- 
Cheers,
Jeff
