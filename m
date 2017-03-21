From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: Re: [PATCH] enic: Store permanent MAC address during probe()
Date: Mon, 20 Mar 2017 18:49:21 -0700
Message-ID: <alpine.LNX.2.20.1703201835570.17033@cisco>
References: <20170320224120.24484-1-pjw@netapp.com> <alpine.LNX.2.20.1703201701590.17033@cisco> <CACMb8d1o=YGsA0VoNQAA6_svLFz3X7EnD4g_AXXvBg2oO_1hjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"; format=flowed
Cc: <netdev@vger.kernel.org>, Christian Benvenuti <benve@cisco.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Neel Patel <neepatel@cisco.com>
To: PJ Waskiewicz <pjwaskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-9.cisco.com ([173.37.86.80]:55241 "EHLO
        rcdn-iport-9.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755352AbdCUB4T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 21:56:19 -0400
In-Reply-To: <CACMb8d1o=YGsA0VoNQAA6_svLFz3X7EnD4g_AXXvBg2oO_1hjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Mar 2017, PJ Waskiewicz wrote:

> On Mon, Mar 20, 2017 at 5:33 PM, Govindarajulu Varadarajan
> <gvaradar@cisco.com> wrote:
>> On Mon, 20 Mar 2017, PJ Waskiewicz wrote:
>>
>>> From: PJ Waskiewicz <pjwaskiewicz@gmail.com>
>>>
>>> The permanent MAC address is useful to store for things like ethtool,
>>> and when bonding with modes such as active/passive or LACP.
>>
>> Is this patch fixing an issue with bonding drive on enic?
>
> We noticed that running ethtool -P <eth> on an enic, even on 4.9,
> returned nothing.  This has fallout when using bonding, where LACP or
> Active/Passive overrides the LAA on one of the slaves, one can't
> figure out what the physical MAC address is of each slave.  So not a
> problem with bonding directly, it's more secondary as a result of the
> driver not reporting the actual permanent address.
>
>>
>>> This follows the model of other Ethernet drivers, such as ixgbe.
>>>
>>
>> While other drivers set netdev->perm_addr, doesn't this actually come free
>> in
>> register_netdevice().
>
> I thought it did as well, but in 4.9 when we tested it wasn't working.
> Hence the patch.  :-)
>

Can you try with net-next? In my setup I do not see the issue on net-next and on
4.9 kernel. The issue for all drivers was fixed in
948b337e62ca9 ("net: init perm_addr in register_netdevice()")
