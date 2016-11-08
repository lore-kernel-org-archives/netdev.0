From: Cao jin <caoj.fnst@cn.fujitsu.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: drop field "tail" of struct
 igb_ring
Date: Tue, 8 Nov 2016 14:07:58 +0800
Message-ID: <58216BBE.5000108@cn.fujitsu.com>
References: <1478522697-4773-1-git-send-email-caoj.fnst@cn.fujitsu.com>
 <CAKgT0UcHutO9kotxN2-MTH=rrB1PjmyMdjyeT4PkYbBXkBquFw@mail.gmail.com>
 <58213D66.5090203@cn.fujitsu.com>
 <CAKgT0UcZiJJbb+-vCkhL=A2X9CB+ekp8-CnTZznEB+NBMYALFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>,
        =?UTF-8?B?SXp1bWksIFRha3Uv5rOJIOaLkw==?=
        <izumi.taku@jp.fujitsu.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKgT0UcZiJJbb+-vCkhL=A2X9CB+ekp8-CnTZznEB+NBMYALFg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 11/08/2016 12:12 PM, Alexander Duyck wrote:
>
>
> On Monday, November 7, 2016, Cao jin <caoj.fnst@cn.fujitsu.com
> <mailto:caoj.fnst@cn.fujitsu.com>> wrote:
>
>

>
> We removed head because it isn't really accessed very often, it is only
> really used for when the ring is configured.  Tail is accessed every
> time we add a descriptor to a ring.  The pointer chasing from ring to
> netdev to adapter to hw is expensive.  That is one of the rasons why
> we cache the pointer to the tail register.

I see. I can submit the patch as you suggested.

>
>             Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
>             ---
>                drivers/net/ethernet/intel/igb/igb.h      |  1 -
>                drivers/net/ethernet/intel/igb/igb_main.c | 16
>             +++++++++-------

>
>     hw->hw_addr could be alterred to NULL(in igb_rd32), this is why
>     writel oops the kernel, you give a fine solution.
>
>     But from the oops message, we can find, register reading returns all
>     F's, I also have a question want to consult: when igb device is
>     reset, would reading register(no matter config space or non-PCIe
>     configuration registers) during reset returns all F's? (I guess this
>     is the core of my issue)
>
>
> An all F's value means the read failed.  The device is likely off of the
> bus and the hw_addr may not have been repopulated after the reset.
>
> You might want to check the mailing list as I thought someone had
> submitted a patch recently for one of the drivers to repopulate hw_addr
> after a reset.
>

I guess you are saying this one:
   http://patchwork.ozlabs.org/patch/689592/

Seems they have a similar issue with me.


-- 
Yours Sincerely,

Cao jin
