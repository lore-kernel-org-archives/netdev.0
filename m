From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v5 0/7]: ixgbevf: Allow querying VFs RSS indirection
 table and key
Date: Sun, 22 Mar 2015 21:05:14 +0200
Message-ID: <550F126A.1000202@cloudius-systems.com>
References: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>	<1420661025.2491.73.camel@jtkirshe-mobl> <CAL3LdT4udpCqSrh8=9zeSQLF_hB9fj-Ocwc3Yxf1Nk64U09BrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Gleb Natapov <gleb@cloudius-systems.com>,
	Avi Kivity <avi@cloudius-systems.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:36420 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbbCVTFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 15:05:17 -0400
Received: by wetk59 with SMTP id k59so121582952wet.3
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 12:05:16 -0700 (PDT)
In-Reply-To: <CAL3LdT4udpCqSrh8=9zeSQLF_hB9fj-Ocwc3Yxf1Nk64U09BrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/06/15 08:52, Jeff Kirsher wrote:
> On Wed, Jan 7, 2015 at 12:03 PM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> On Wed, 2015-01-07 at 21:26 +0200, Vlad Zolotarov wrote:
>>> Add the ethtool ops to VF driver to allow querying the RSS indirection
>>> table
>>> and RSS Random Key.
>>>
>>> On some devices VFs share the RSS Redirection Table and Hash Key with
>>> a PF and letting
>>> the VF query this information may introduce some security risks.
>>> Therefore we disable this
>>> feature by default for such devices (e.g. 82599) and allow it for
>>> those where there isn't any
>>> possible risk (e.g. on x550). The new netdev op is going to allow a
>>> system administrator to
>>> change the default behaviour with "ip link set" command.
>>>
>>>   - netdev: Add a new netdev op to allow/block VF from querying RSS
>>> Indirection Table and
>>>     RSS Hash Key.
>>>   - PF driver: Add new VF-PF channel commands.
>>>   - VF driver: Utilize these new commands and add the corresponding
>>>                ethtool callbacks.
>>>
>>> New in v5:
>>>     - Added a new netdev op to allow/block VF from querying RSS
>>> Indirection Table and
>>>       RSS Hash Key.
>>>     - Let VF query the RSS info only if VF is allowed to.
>>>
>>> New in v4:
>>>     - Forgot to run checkpatch on v3 and there were a few styling
>>> things to fix. ;)
>>>
>>> New in v3:
>>>     - Added a missing support for x550 devices.
>>>     - Mask the indirection table values according to PSRTYPE[n].RQPL.
>>>     - Minimized the number of added VF-PF commands.
>>>
>>> New in v2:
>>>     - Added a detailed description to patches 4 and 5.
>>>
>>> New in v1 (compared to RFC):
>>>     - Use "if-else" statement instead of a "switch-case" for a single
>>> option case.
>>>       More specifically: in cases where the newly added API version is
>>> the only one
>>>       allowed. We may consider using a "switch-case" back again when
>>> the list of
>>>       allowed API versions in these specific places grows up.
>>>
>>> Vlad Zolotarov (7):
>>>    if_link: Add an additional parameter to ifla_vf_info for RSS
>>> querying
>>>    ixgbe: Add a new netdev op to allow/prevent a VF from querying an
>>> RSS
>>>      info
>>>    ixgbe: Add a RETA query command to VF-PF channel API
>>>    ixgbevf: Add a RETA query code
>>>    ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
>>>    ixgbevf: Add RSS Key query code
>>>    ixgbevf: Add the appropriate ethtool ops to query RSS indirection
>>>      table and key
>>>
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 +
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   7 ++
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 119
>>> +++++++++++++++++++
>>>   drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   2 +
>>>   drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  42 +++++++
>>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
>>>   drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
>>>   drivers/net/ethernet/intel/ixgbevf/vf.c           | 132
>>> ++++++++++++++++++++++
>>>   drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
>>>   include/linux/if_link.h                           |   1 +
>>>   include/linux/netdevice.h                         |   8 ++
>>>   include/uapi/linux/if_link.h                      |   8 ++
>>>   net/core/rtnetlink.c                              |  33 +++++-
>>>   14 files changed, 372 insertions(+), 7 deletions(-)
>> Thanks Vlad, I will add your patches to my queue.
> Validation ran into issues with your patch series, they reported the following:
> Ethtool has "Cannot get RX ring count: Operation not supported" errors
> when trying to access RSS flow hash table.
>
> So I am dropping the series for now and will await a v6.

v6 is out. I've verified the series on x540 device. Pls., note that u'll 
need my patch for "ip" tool to toggle the VF query ability if u use x540 
or 82599 devices.

thanks,
vlad

>
