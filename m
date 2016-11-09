From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH RFC 0/2] ethtool: Add actual port speed reporting
Date: Wed, 9 Nov 2016 11:32:50 +0200
Message-ID: <CALzJLG8Ns+fA7cJHVN9wj_6COF71mu5CPOYWK+UR3r+X7+paLA@mail.gmail.com>
References: <1478100914-23610-1-git-send-email-galp@mellanox.com> <BL2PR07MB23069B0DB17B981AA43775B18DA00@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gal Pressman <galp@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "John W. Linville" <linville@tuxdriver.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        David Decotigny <decot@googlers.com>,
        Ben Hutchings <ben@decadent.org.uk>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33392 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbcKIJdM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 04:33:12 -0500
Received: by mail-lf0-f68.google.com with SMTP id 98so9508915lfs.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 01:33:11 -0800 (PST)
In-Reply-To: <BL2PR07MB23069B0DB17B981AA43775B18DA00@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 2, 2016 at 5:50 PM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> Sending RFC to get feedback for the following ethtool proposal:
>>
>> In some cases such as virtual machines and multi functions (SR-IOV), the actual
>> bandwidth exposed for each machine is not accurately shown in ethtool.
>> Currently ethtool shows only physical port link speed.
>> In our case we would like to show the virtual port operational link speed which
>> in some cases is less than the physical port speed.
>>
>> This will give users better visibility for the actual speed running on their device.
>>
>> $ ethtool ens6
>> ...
>> Speed: 50000Mb/s
>> Actual speed: 25000Mb/s
>
> Not saying this is a bad thing, but where exactly is it listed that ethtool has
> to show the physical port speed?

Well, looking at the ethtool fields you can clearly see those fields
refer only to physical properties of port connector module.
from this you can conclude that the speed field refers to the physical
port speed.

Settings for ens1f0:
Supported ports: [ FIBRE Backplane ]
Supported link modes:   1000baseKX/Full
                       10000baseKR/Full
                       40000baseKR4/Full
                       40000baseCR4/Full
                       40000baseSR4/Full
                       40000baseLR4/Full
                       25000baseCR/Full
                       25000baseKR/Full
                       25000baseSR/Full
                       50000baseCR2/Full
                       50000baseKR2/Full
                       100000baseKR4/Full
                       100000baseSR4/Full
                       100000baseCR4/Full
                       100000baseLR4_ER4/Full
Supported pause frame use: Symmetric Receive-only
Supports auto-negotiation: Yes
Advertised link modes:  1000baseKX/Full
                       10000baseKR/Full
                       40000baseKR4/Full
                       40000baseCR4/Full
                       40000baseSR4/Full
                       40000baseLR4/Full
                       25000baseCR/Full
                       25000baseKR/Full
                       25000baseSR/Full
                       50000baseCR2/Full
                       50000baseKR2/Full
                       100000baseKR4/Full
                       100000baseSR4/Full
                       100000baseCR4/Full
                       100000baseLR4_ER4/Full
Advertised pause frame use: No
Advertised auto-negotiation: Yes
Speed: 100000Mb/s
Duplex: Full
Port: Direct Attach Copper
PHYAD: 0
Transceiver: internal
Auto-negotiation: on
Supports Wake-on: d
Wake-on: d
Link detected: yes

> E.g., bnx2x shows the logical speed instead, and has been doing that for years.
> [Perhaps that's a past wrongness, but that's how it goes].
>
> And besides, one can argue that in the SR-IOV scenario the VF has no business
> knowing the physical port speed.

Yes for SR-IOV VFs one field (logical) is sufficient.
But in some cases on a native system (no SR-IOV nor virtualization)
there will be a need for both physical and logical speed reporting.
logical speed can be limited for several reasons (NIC Low power mode,
pci (width,gen), Internal HCA rate limiters, etc ... ).

Such information will be more than useful for system administrators
and will not be available if we decide to show only one field.

-Saeed.
