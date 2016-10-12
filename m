From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next] mlx5: Add MLX5_SET64_VCHK to fix BUILD_BUG_ON
Date: Wed, 12 Oct 2016 11:03:51 +0900
Message-ID: <CALzJLG9f-M5OT=_W-4RO7UK+53RMrXo-BPXYtbwTuNWG-bn4Sw@mail.gmail.com>
References: <20161011042222.2366145-1-tom@herbertland.com> <063D6719AE5E284EB5DD2968C1650D6DB01E62DC@AcuExch.aculab.com>
 <CALzJLG_9Yr=jCPix2Oisxf22CLHxtYYyXejYxkBi-A85kZ_Shw@mail.gmail.com>
 <CALx6S346RSTg6Knik5J4-BdvnTLrx28y-ADCt9ga344OFq4V0w@mail.gmail.com> <20161011194000.GO9282@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
        David Laight <David.Laight@aculab.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "kernel-team@fb.com" <kernel-team@fb.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33878 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752757AbcJLCEy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 22:04:54 -0400
Received: by mail-lf0-f68.google.com with SMTP id p80so5670334lfp.1
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 19:04:13 -0700 (PDT)
In-Reply-To: <20161011194000.GO9282@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2016 at 4:40 AM, Leon Romanovsky <leon@kernel.org> wrote:
> On Tue, Oct 11, 2016 at 08:46:45AM -0700, Tom Herbert wrote:
>> On Tue, Oct 11, 2016 at 4:57 AM, Saeed Mahameed
>> <saeedm@dev.mellanox.co.il> wrote:
>> > On Tue, Oct 11, 2016 at 7:50 PM, David Laight <David.Laight@aculab.com> wrote:
>> >> From: Tom Herbert
>> >>> Sent: 11 October 2016 05:22
>> >> ...
>> >>> Fix is to create MLX5_SET64_VCHK that takes an additional argument
>> >>> that is a constant. There are two callers of MLX5_SET64 that are
>> >>> trying to get a variable offset, change those to call MLX5_SET64_VCHK
>> >>> passing pas[0] as the argument to use in the offset check.
>> >>
>> >> I think I'd separate the array index instead.
>> >> Something like:
>> >>
>> >> #define MLX5_SET64_INDEXED(typ, p, fld, ndx, v) do { \
>> >>         BUILD_BUG_ON(__mlx5_bit_off(typ, fld) % 64); \
>> >>         __MLX5_SET64(typ, p, fld[ndx], v); \
>> >> } while (0)
>> >>
>> >>         David
>> >
>> > Yes, I think this looks more natural, but instead MLX5_SET64_INDEXED,
>> > I prefer to have 2 macros
>> > MLX5_SET64(typ, p, fld, v) and MLX5_ARRAY_SET64(typ, p, fld, idx, v).
>> >
>> > Tom, do you want me to fix it ?
>> >
>> Please do.
>
> Saeed,
>
> Do you success to send this patch before -rc1 is released? So Linus's
> -rc1 will be clean from such build error.
>

Just submitted the patch, it seems that i have issues with my other
Mailer, sometimes e-mails take a while to appear in the mailing list.
I Hope the patch will arrive on time for Dave to pick it it up.

Thanks,
-Saeed.
