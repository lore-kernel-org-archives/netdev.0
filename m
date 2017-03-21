From: PJ Waskiewicz <pjwaskiewicz@gmail.com>
Subject: Re: [PATCH] enic: Store permanent MAC address during probe()
Date: Mon, 20 Mar 2017 17:37:26 -0700
Message-ID: <CACMb8d1o=YGsA0VoNQAA6_svLFz3X7EnD4g_AXXvBg2oO_1hjQ@mail.gmail.com>
References: <20170320224120.24484-1-pjw@netapp.com> <alpine.LNX.2.20.1703201701590.17033@cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Christian Benvenuti <benve@cisco.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Neel Patel <neepatel@cisco.com>
To: Govindarajulu Varadarajan <gvaradar@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:35651 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755929AbdCUAhd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 20:37:33 -0400
Received: by mail-pg0-f47.google.com with SMTP id t143so19412792pgb.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 17:37:32 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.20.1703201701590.17033@cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 5:33 PM, Govindarajulu Varadarajan
<gvaradar@cisco.com> wrote:
> On Mon, 20 Mar 2017, PJ Waskiewicz wrote:
>
>> From: PJ Waskiewicz <pjwaskiewicz@gmail.com>
>>
>> The permanent MAC address is useful to store for things like ethtool,
>> and when bonding with modes such as active/passive or LACP.
>
>
> Hi Peter,
>
> Is this patch fixing an issue with bonding drive on enic?

We noticed that running ethtool -P <eth> on an enic, even on 4.9,
returned nothing.  This has fallout when using bonding, where LACP or
Active/Passive overrides the LAA on one of the slaves, one can't
figure out what the physical MAC address is of each slave.  So not a
problem with bonding directly, it's more secondary as a result of the
driver not reporting the actual permanent address.

>
>> This follows the model of other Ethernet drivers, such as ixgbe.
>>
>
> While other drivers set netdev->perm_addr, doesn't this actually come free
> in
> register_netdevice().

I thought it did as well, but in 4.9 when we tested it wasn't working.
Hence the patch.  :-)

Cheers,
-PJ
