From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Subject: Re: 802.3ad bonding aggregator reselection
Date: Tue, 21 Jun 2016 23:48:05 +0300
Message-ID: <CAKdSkDWo-fwEMkZGQn2gkL+wT2yWEv1k-t+vVanZ-Cxzi=PcXQ@mail.gmail.com>
References: <CAKdSkDUb94mR7cDiZbxsc6fgm_8O5wagjUec4g-t5DF7R_GFDw@mail.gmail.com>
 <CAKdSkDUfat0bM=WBv-Numnaa0MVKu2V6Rcx8eUeTZjcuDiYLpw@mail.gmail.com>
 <CAD=hENdGOFY5027964=f3xk_qeNmVccHYvr2rvTJtpFmaeFG2w@mail.gmail.com>
 <CAKdSkDXPYPvHh=AOyysAPWpR0eoMf-wobCTdi35GsF3FYbLxag@mail.gmail.com> <13338.1466523960@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: zhuyj <zyjzyj2000@gmail.com>, netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:36079 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbcFUUtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 16:49:55 -0400
Received: by mail-oi0-f43.google.com with SMTP id f189so3158706oig.3
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 13:48:06 -0700 (PDT)
In-Reply-To: <13338.1466523960@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-06-21 18:46 GMT+03:00 Jay Vosburgh <jay.vosburgh@canonical.com>:
> Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:
>
>>2016-06-20 17:11 GMT+03:00 zhuyj <zyjzyj2000@gmail.com>:
>>> 5. Switch Configuration
>>> =======================
>>>
>>>         For this section, "switch" refers to whatever system the
>>> bonded devices are directly connected to (i.e., where the other end of
>>> the cable plugs into).  This may be an actual dedicated switch device,
>>> or it may be another regular system (e.g., another computer running
>>> Linux),
>>>
>>>         The active-backup, balance-tlb and balance-alb modes do not
>>> require any specific configuration of the switch.
>>>
>>>         The 802.3ad mode requires that the switch have the appropriate
>>> ports configured as an 802.3ad aggregation.  The precise method used
>>> to configure this varies from switch to switch, but, for example, a
>>> Cisco 3550 series switch requires that the appropriate ports first be
>>> grouped together in a single etherchannel instance, then that
>>> etherchannel is set to mode "lacp" to enable 802.3ad (instead of
>>> standard EtherChannel).
>>
>>The ports are configured in switch settings (HP Procurve 2530-48G) in
>>same trunk group (TrkX) and trunk group type is set as LACP.
>>/proc/net/bonding/bond0 also shows that the three ports belong to same
>>aggregator and bandwidth tests also support this. In my understanding
>>Procurve's trunk group is pretty much the same as etherchannel in
>>Cisco's terminology. The bonded link comes always up properly, but
>>handling of links going down is the problem. Are there known
>>differences between different vendors there?
>
>         I did the original LACP reselection testing on a Cisco switch,
> but I have an HP 2530 now; I'll test it later today or tomorrow and see
> if it behaves properly, and whether your proposed patch is needed.

Thanks for taking a look at this. Here are some more details about the
setup as Zhu Yanjun also requested.

The server in question has two internal 10Gbps ports (using ixgbe) and
two Intel I350 T2 dual-1Gbps PCIe-cards (using igb). All ports are
using 1Gbps connections.

05:00.0 Ethernet controller: Intel Corporation Ethernet Controller
10-Gigabit X540-AT2 (rev 01)
05:00.1 Ethernet controller: Intel Corporation Ethernet Controller
10-Gigabit X540-AT2 (rev 01)
81:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network
Connection (rev 01)
81:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network
Connection (rev 01)
82:00.0 Ethernet controller: Intel Corporation I350 Gigabit Network
Connection (rev 01)
82:00.1 Ethernet controller: Intel Corporation I350 Gigabit Network
Connection (rev 01)

In the test setup the bonds are setup as:

05:00.0 + 81:00.0 + 82:00.0 and
05:00.1 + 81:00.1 + 82:00.1

So each bond uses one port using ixgbe and two ports using igbe.

When testing, I have disabled the port in the switch configuration
that brings down the link and also miimon sees the link going down on
the server. This should be the same as unplugging the cable, so
there's nothing coming through the wire to the server.

Veli-Matti
