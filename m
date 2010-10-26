From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: __bad_udelay in network driver breaks build
Date: Tue, 26 Oct 2010 10:34:40 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F25BCE9E78C@orsmsx501.amr.corp.intel.com>
References: <20101018115230.GA27565@basil.fritz.box>
 <20101025.130513.102558756.davem@davemloft.net>
 <20101025221042.GE17622@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22421 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759926Ab0JZRem convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 13:34:42 -0400
In-Reply-To: <20101025221042.GE17622@basil.fritz.box>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Andi Kleen [mailto:andi@firstfloor.org]
>Sent: Monday, October 25, 2010 3:11 PM
>To: David Miller
>Cc: andi@firstfloor.org; netdev@vger.kernel.org; Kirsher, Jeffrey T;
>Duyck, Alexander H
>Subject: Re: __bad_udelay in network driver breaks build
>
>On Mon, Oct 25, 2010 at 01:05:13PM -0700, David Miller wrote:
>> From: Andi Kleen <andi@firstfloor.org>
>> Date: Mon, 18 Oct 2010 13:52:30 +0200
>>
>> >
>> > Current Linus master x86-64 allyesconfig fails with
>> >
>> > drivers/built-in.o: In function `tms380tr_chipset_init':
>> > tms380tr.c:(.text+0x10f02de): undefined reference to
>`__bad_udelay'
>> > tms380tr.c:(.text+0x10f03ab): undefined reference to
>`__bad_udelay'
>> > tms380tr.c:(.text+0x10f0400): undefined reference to
>`__bad_udelay'
>> > tms380tr.c:(.text+0x10f07b2): undefined reference to
>`__bad_udelay'
>> > tms380tr.c:(.text+0x10f08ed): undefined reference to
>`__bad_udelay'
>> > make[2]: *** [.tmp_vmlinux1] Error 1
>>
>> Let me know if this fixes things:
>
>Fixes that problem, but now I get (with Linus' latest again and a gcc
>4.6
>snapshot)
>
>In file included from /home/lsrc/git/linux-
>2.6/drivers/net/igbvf/ethtool.c:36:0:
>/home/lsrc/git/linux-2.6/drivers/net/igbvf/igbvf.h:129:15: error:
>duplicate member 'page'
>make[5]: *** [drivers/net/igbvf/ethtool.o] Error 1
>make[4]: *** [drivers/net/igbvf] Error 2
>
>struct igbvf_buffer {
>        dma_addr_t dma;
>        struct sk_buff *skb;
>        union {
>                /* Tx */
>                struct {
>                        unsigned long time_stamp;
>                        u16 length;
>                        u16 next_to_watch;
>                        u16 mapped_as_page;
>                };
>                /* Rx */
>                struct {
>                        struct page *page; <--------------- No 1
>                        u64 page_dma;
>                        unsigned int page_offset;
>                };
>        };
>        struct page *page;         <------------ No 2
>};
>
>Hmm conflict of a member with a transparent union.
>Maybe older gccs didn't catch that. But it looks very broken
>
>Alexander, can you sort out which "page" member should be used where?
>
>And there's another problem in SCSI which I'll report separately.
>
>-Andi

Yeah, I'm pretty sure the 2nd page pointer shouldn't be there.  We will look into correcting that.

Thanks,

Alex

