From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next] net:add one common config ARCH_WANT_RELAX_ORDER
 to support relax ordering.
Date: Wed, 18 Jan 2017 09:25:09 -0800
Message-ID: <CAKgT0Ud5K4GZtbyNOMUh=o8oGTukPA7qvvnK6ptO+KwaTSqGkA@mail.gmail.com>
References: <1483939954-9864-1-git-send-email-maowenan@huawei.com>
 <20170117.141533.680344033700095483.davem@davemloft.net> <063D6719AE5E284EB5DD2968C1650D6DB0266CD6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "maowenan@huawei.com" <maowenan@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34939 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751292AbdARRZo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 12:25:44 -0500
Received: by mail-io0-f193.google.com with SMTP id m98so2329054iod.2
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 09:25:11 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0266CD6@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 8:22 AM, David Laight <David.Laight@aculab.com> wrote:
> From: David Miller
>> Sent: 17 January 2017 19:16
>> > Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
>> > enhance the performance for some cpu architecure, such as SPARC and so on.
>> > Currently it only supports one special cpu architecture(SPARC) in 82599
>> > driver to enable RO feature, this is not very common for other cpu architecture
>> > which really needs RO feature.
>> > This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to set RO feature,
>> > and should define CONFIG_ARCH_WANT_RELAX_ORDER in sparc Kconfig firstly.
>> >
>> > Signed-off-by: Mao Wenan <maowenan@huawei.com>
>>
>> Since no-one has reviewed this patch, and I do not feel comfortable with applying
>> it without such review, I am tossing this patch.
>>
>> If someone eventually reviews it, repost this patch.
>
> Having re-read parts of the PCIe spec I think I'd like someone to
> explain exactly which transfers are affected by the 'relaxed ordering'
> bit and why any re-ordered transactions aren't a problem.
>
> In particular I believe RO allows the write to update the receive
> descriptor ring to overtake a write of receive packet data.
> That could lead to the network stack processing a receive frame
> before it has actually been written.
>
>         David
>

The Relaxed Ordering attribute doesn't get applied across the board.
It ends up being limited to a subset of the transactions if I recall
correctly.  In this case it is the Tx descriptor write back, and the
Rx data write back.  We don't apply the RO bit to any other
transactions.

In the case of Tx descriptor there is no harm in allowing it to be
reordered because we only really read the DD bit so we don't care
about the ordering of the write back.  In the case of the Rx data the
Rx descriptor essentially acts as a flush since it is sent without the
RO bit set.  So all the writes before it must be completed before the
Rx descriptor write back.

- Alex
