From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net 7/8] net/mlx5e: Fix update of hash function/key via ethtool
Date: Sat, 28 Jan 2017 13:06:31 +0200
Message-ID: <CALzJLG_s=bsGm+KsLLbvCu07j485-bBs+sySYAqicXnqnSnkZA@mail.gmail.com>
References: <20170127203843.3206-1-saeedm@mellanox.com> <20170127203843.3206-8-saeedm@mellanox.com>
 <CALx6S35H0n5MTjzjMJxnRegWBsznqccAohih-GkioifBqZTR5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Gal Pressman <galp@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33101 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750828AbdA1LGw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 06:06:52 -0500
Received: by mail-qk0-f170.google.com with SMTP id s140so87560864qke.0
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 03:06:52 -0800 (PST)
In-Reply-To: <CALx6S35H0n5MTjzjMJxnRegWBsznqccAohih-GkioifBqZTR5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 11:50 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, Jan 27, 2017 at 12:38 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>> From: Gal Pressman <galp@mellanox.com>
>>
>> Modifying TIR hash should change selected fields bitmask in addition to
>> the function and key.
>> Formerly, we would not set this field resulting in zeroing of its value,
>> which means no packet fields are used for RX RSS hash calculation thus
>> causing all traffic to arrive in RQ[0].
>>
> This commit log is rather scant in details. Does this mean that RSS is
> somehow broken in mlx5? What is exact test that demonstrates bad
> behavior? Did you verify that this doesn't break IPv4 or IPv6?
>

before this fix out of the box RSS worked fine for both IPv4/IPv6, the
only broken flow is when the user explicitly uses ethtoo -X to update
the RSS indirection table or hash function.

We did verify both IPv6 and IPv4 RSS worked fine after the user
changes RSS configuration via ethtool -X
