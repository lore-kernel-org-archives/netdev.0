From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx5: Add MLX5_SET64_VCHK to fix BUILD_BUG_ON
Date: Tue, 11 Oct 2016 20:57:11 +0900
Message-ID: <CALzJLG_9Yr=jCPix2Oisxf22CLHxtYYyXejYxkBi-A85kZ_Shw@mail.gmail.com>
References: <20161011042222.2366145-1-tom@herbertland.com> <063D6719AE5E284EB5DD2968C1650D6DB01E62DC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "kernel-team@fb.com" <kernel-team@fb.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33608 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751953AbcJKL7Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 07:59:25 -0400
Received: by mail-lf0-f67.google.com with SMTP id l131so629068lfl.0
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 04:57:32 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB01E62DC@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2016 at 7:50 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Tom Herbert
>> Sent: 11 October 2016 05:22
> ...
>> Fix is to create MLX5_SET64_VCHK that takes an additional argument
>> that is a constant. There are two callers of MLX5_SET64 that are
>> trying to get a variable offset, change those to call MLX5_SET64_VCHK
>> passing pas[0] as the argument to use in the offset check.
>
> I think I'd separate the array index instead.
> Something like:
>
> #define MLX5_SET64_INDEXED(typ, p, fld, ndx, v) do { \
>         BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
>         __MLX5_SET64(typ, p, fld[ndx], v); \
> } while (0)
>
>         David

Yes, I think this looks more natural, but instead MLX5_SET64_INDEXED,
I prefer to have 2 macros
MLX5_SET64(typ, p, fld, v) and MLX5_ARRAY_SET64(typ, p, fld, idx, v).

Tom, do you want me to fix it ?

Thanks,
Saeed.
