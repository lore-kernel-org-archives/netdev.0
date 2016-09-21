From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 11:50:06 -0700
Message-ID: <CALx6S34c6Mz=YpbiPcVNe38wTkxfjB9SWxaqtz1LivLeGzssRQ@mail.gmail.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com> <57E1CDE3.5030404@fb.com>
 <20160921182657.67681e67@jkicinski-Precision-T1700> <CALx6S37CkP44ZSNZM3UNBMv_ECFS6tf5T_37VSMyBCjm9ejiDw@mail.gmail.com>
 <20160921194548.33b85cb3@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36402 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933016AbcIUSuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 14:50:08 -0400
Received: by mail-qk0-f171.google.com with SMTP id z190so54820965qkc.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 11:50:07 -0700 (PDT)
In-Reply-To: <20160921194548.33b85cb3@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 11:45 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Wed, 21 Sep 2016 10:39:40 -0700, Tom Herbert wrote:
>> On Wed, Sep 21, 2016 at 10:26 AM, Jakub Kicinski <kubakici@wp.pl> wrote:
>> > On Tue, 20 Sep 2016 17:01:39 -0700, Alexei Starovoitov wrote:
>> >>  >  - Reduces the amount of code and complexity needed in drivers to
>> >>  >    manage XDP
>> >>
>> >> hmm:
>> >> 534 insertions(+), 144 deletions(-)
>> >> looks like increase in complexity instead.
>> >
>> > and more to come to tie this with HW offloads.
>>
>> The amount of driver code did decrease with these patches:
>>
>> drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 64 ++++----------------------
>> drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 25 ++++------
>> drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 -
>>
>> Minimizing complexity being added to drivers for XDP is critical since
>> we basically asking every driver to replicate the function. This
>> property also should also apply to HW offloads, the more complexity we
>> can abstract out drivers into a common backend infrastructure the
>> better for supporting across different drivers.
>
> I'm in the middle of writing/testing XDP support for the Netronome's
> driver and generic infra is very much appreciated ;)  In my experience
> the 50 lines of code which are required for assigning the programs and
> freeing them aren't really a big deal, though.
>

50 lines in one driver is not a big deal, 50 lines in a hundred
drivers is! I learned this lesson in BQL which was well abstracted out
to be minimally invasive but we still saw many issues because of the
pecularities of different drivers.

> Let's also separate putting xdp_prog in netdevice/napi_struct from the
> generic hook infra.  All the simplifications to the driver AFAICS come
> from the former.  If everyone is fine with growing napi_struct we can do
> that but IMHO this is not an argument for the generic infra :)
