From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [next:akpm 16/587] drivers/net/ethernet/intel/igb/igb_main.c:6231:2:
 error: call to '__compiletime_assert_6235' declared with attribute error:
 BUILD_BUG_ON failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD +
 NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH...
Date: Tue, 19 Feb 2013 17:09:24 -0800
Message-ID: <CAL4WiirCCfN_Xi423sEJB5v=5hCR_3d8M26JmmG3VJ=fbH4-1g@mail.gmail.com>
References: <5122101a.nBjTqFyZXZ+WuzPr%fengguang.wu@intel.com>
	<20130219142708.b454d98a.akpm@linux-foundation.org>
	<804857E1F29AAC47BF68C404FC60A1844D0099DF@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Wu, Fengguang" <fengguang.wu@intel.com>,
	Daniel Santos <daniel.santos@pobox.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:34216 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932307Ab3BTBJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 20:09:25 -0500
Received: by mail-oa0-f54.google.com with SMTP id n12so7517146oag.27
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 17:09:25 -0800 (PST)
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1844D0099DF@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2013 at 2:30 PM, Allan, Bruce W <bruce.w.allan@intel.com> wrote:
>> -----Original Message-----
>> From: Andrew Morton [mailto:akpm@linux-foundation.org]
>> Sent: Tuesday, February 19, 2013 2:27 PM
>> To: Wu, Fengguang
>> Cc: Daniel Santos; Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W;
>> netdev@vger.kernel.org
>> Subject: Re: [next:akpm 16/587]
>> drivers/net/ethernet/intel/igb/igb_main.c:6231:2: error: call to
>> '__compiletime_assert_6235' declared with attribute error: BUILD_BUG_ON
>> failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD +
>> NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH...
>>
>> On Mon, 18 Feb 2013 19:27:22 +0800
>> kbuild test robot <fengguang.wu@intel.com> wrote:
>>
>> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
>> akpm
>> > head:   ae9da2a24a80423b8dbda9c5a72674ce6e7861be
>> > commit: f7d7e38e6df399b2af7f04c177054abdd744a077 [16/587] bug.h,
>> compiler.h: Introduce compiletime_assert & BUILD_BUG_ON_MSG
>> > config: make ARCH=s390 allmodconfig
>> >
>> > All error/warnings:
>> >
>> >    In function 'igb_build_rx_buffer',
>> >        inlined from 'igb_clean_rx_irq' at
>> drivers/net/ethernet/intel/igb/igb_main.c:6705:8:
>> > >> drivers/net/ethernet/intel/igb/igb_main.c:6231:2: error: call to
>> '__compiletime_assert_6235' declared with attribute error: BUILD_BUG_ON
>> failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD +
>> NET_IP_ALIGN + IGB_TS_HDR_LEN + ETH_FRAME_LEN + ETH_FCS_LEN)
>> >
>> > vim +/__compiletime_assert_6235 +6231
>> drivers/net/ethernet/intel/igb/igb_main.c
>> >
>> >   6225      #endif
>> >   6226
>> >   6227              /* If we spanned a buffer we have a huge mess so test for it
>> */
>> >   6228              BUG_ON(unlikely(!igb_test_staterr(rx_desc,
>> E1000_RXD_STAT_EOP)));
>> >   6229
>> >   6230              /* Guarantee this function can be used by verifying buffer
>> sizes */
>> > > 6231
>>       BUILD_BUG_ON(SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) <
>> (NET_SKB_PAD +
>> >   6232
>>       NET_IP_ALIGN +
>> >   6233
>>       IGB_TS_HDR_LEN +
>> >   6234
>>       ETH_FRAME_LEN +
>> >
>>
>> That BUILD_BUG_ON() triggers without Daniel's patches applied as well:
>>
>>   CC [M]  drivers/net/ethernet/intel/igb/igb_main.o
>> drivers/net/ethernet/intel/igb/igb_main.c: In function
>> 'igb_build_rx_buffer':
>> drivers/net/ethernet/intel/igb/igb_main.c:6231: error: size of array 'type
>> name' is negative
>>
>> I suspect that driver is busted on s390.  Dunno why.  Here's what cpp emits:
>>
>>
>> s390 allmodconfig:
>>
>> bool __cond = !(!(((2048) - (((sizeof(struct skb_shared_info)) + (256 - 1)) &
>> ~(256 - 1))) < (32 + 2 + 16 + 1514 + 4)));
>>
>>
>> x86_64 allmodconfig:
>>
>> bool __cond = !(!(((2048) - (((sizeof(struct skb_shared_info)) + ((1 <<
>> (6)) - 1)) & ~((1 << (6)) - 1))) < (({ typeof(32) _max1 = (32); typeof((1
>> << (6))) _max2 = ((1 << (6))); (void) (&_max1 == &_max2); _max1 > _max2 ?
>> _max1 : _max2; }) + 0 + 16 + 1514 + 4)));
>>
>>
>> I doubt if anyone will be running this driver on s390, but I guess we
>> should work out why it broke.
>
> Adding Intel wired ethernet developers mailing list.
>

Oh well, NET_SKB_PAD is too large on s390

I guess we should use 64 bytes max.

#define NET_SKB_PAD  min(64, max(32, L1_CACHE_BYTES))
