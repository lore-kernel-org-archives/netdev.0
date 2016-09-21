From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next 02/15] i40e: Enable VF specific ethtool statistics via
 VF Port representor netdevs
Date: Wed, 21 Sep 2016 07:26:23 +0300
Message-ID: <CAJ3xEMhM63HxyQxv3YyN7Lb3uCOWsA3aqfkhnuzdJqtNRty8Zw@mail.gmail.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com> <1474429432-102772-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Sridhar Samudrala <sridhar.samudrala@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>,
        guru.anbalagane@oracle.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35464 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750862AbcIUE0Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 00:26:24 -0400
Received: by mail-oi0-f65.google.com with SMTP id n202so2918115oig.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 21:26:24 -0700 (PDT)
In-Reply-To: <1474429432-102772-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 6:43 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Sridhar Samudrala <sridhar.samudrala@intel.com>
>
> Sample script that shows ethtool stats on VF representor netdev
> PF: enp5s0f0, VF0: enp5s2  VF_REP0: enp5s0f0-vf0
>
>    # echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
>    # ip link set enp5s2 up
>    # ethtool -S enp5s0f0-vf0
>    NIC statistics:
>      tx_bytes: 0
>      tx_unicast: 0
>      tx_multicast: 0
>      tx_broadcast: 0
>      tx_discards: 0
>      tx_errors: 0
>      rx_bytes: 140
>      rx_unicast: 0
>      rx_multicast: 2
>      rx_broadcast: 0
>      rx_discards: 0
>      rx_unknown_protocol: 0

Now, when the SW stats are finally upstream for 4.9 in net-next, the
correct approach
for the VF reps counters is to follow the architecture presented there
[1] -- and this is
for the netlink based standard counters. Once you do that, there's no
need to expose
the VF HW counters through  ethtool of the VF rep.

Or.


[1] offloaded stats commits
a5ea31f Merge branch 'net-offloaded-stats'
fc1bbb0 mlxsw: spectrum: Implement offload stats ndo and expose HW
stats by default
69ae6ad net: core: Add offload stats to if_stats_msg
2c9d85d netdevice: Add offload statistics ndo
