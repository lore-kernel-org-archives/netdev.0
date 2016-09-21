From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next 02/15] i40e: Enable VF specific ethtool statistics
 via VF Port representor netdevs
Date: Tue, 20 Sep 2016 22:59:15 -0700
Message-ID: <57E221B3.2000004@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com> <1474429432-102772-3-git-send-email-jeffrey.t.kirsher@intel.com> <CAJ3xEMhM63HxyQxv3YyN7Lb3uCOWsA3aqfkhnuzdJqtNRty8Zw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        guru.anbalagane@oracle.com
To: Or Gerlitz <gerlitz.or@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44045 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750752AbcIUF7R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 01:59:17 -0400
In-Reply-To: <CAJ3xEMhM63HxyQxv3YyN7Lb3uCOWsA3aqfkhnuzdJqtNRty8Zw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 9/20/2016 9:26 PM, Or Gerlitz wrote:
> On Wed, Sep 21, 2016 at 6:43 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
>> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
>>
>> Sample script that shows ethtool stats on VF representor netdev
>> PF: enp5s0f0, VF0: enp5s2  VF_REP0: enp5s0f0-vf0
>>
>>     # echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
>>     # ip link set enp5s2 up
>>     # ethtool -S enp5s0f0-vf0
>>     NIC statistics:
>>       tx_bytes: 0
>>       tx_unicast: 0
>>       tx_multicast: 0
>>       tx_broadcast: 0
>>       tx_discards: 0
>>       tx_errors: 0
>>       rx_bytes: 140
>>       rx_unicast: 0
>>       rx_multicast: 2
>>       rx_broadcast: 0
>>       rx_discards: 0
>>       rx_unknown_protocol: 0
> Now, when the SW stats are finally upstream for 4.9 in net-next, the
> correct approach
> for the VF reps counters is to follow the architecture presented there
> [1] -- and this is
> for the netlink based standard counters. Once you do that, there's no
> need to expose
> the VF HW counters through  ethtool of the VF rep.
Sure. Will look into it.  However, i think we can keep ethtool support 
also as VFPR
represents the switch port corresponding to the VF.

>
> Or.
>
>
> [1] offloaded stats commits
> a5ea31f Merge branch 'net-offloaded-stats'
> fc1bbb0 mlxsw: spectrum: Implement offload stats ndo and expose HW
> stats by default
> 69ae6ad net: core: Add offload stats to if_stats_msg
> 2c9d85d netdevice: Add offload statistics ndo
