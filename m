From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: add driver for Netronome NFP4000/NFP6000 NIC
 VFs
Date: Tue, 27 Oct 2015 06:45:52 -0700 (PDT)
Message-ID: <20151027.064552.1983883459752923442.davem@davemloft.net>
References: <1445626691-19819-3-git-send-email-jakub.kicinski@netronome.com>
	<20151026.182307.873190227567325622.davem@davemloft.net>
	<20151027111603.77111ce4@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rolf.neugebauer@netronome.com,
	jason.mcmullan@netronome.com, simon.horman@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38330 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbbJ0N3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 09:29:17 -0400
In-Reply-To: <20151027111603.77111ce4@jkicinski-Precision-T1700>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 27 Oct 2015 11:16:03 +0000

> On Mon, 26 Oct 2015 18:23:07 -0700 (PDT), David Miller wrote:
>> From: Jakub Kicinski <jakub.kicinski@netronome.com>
>> Date: Fri, 23 Oct 2015 19:58:11 +0100
>> 
>> > +struct nfp_net_tx_buf {
>> > +	struct sk_buff *skb;
>> > +	dma_addr_t dma_addr;
>> > +	short int fidx;
>> > +	u16 pkt_cnt;
>> > +	u32 real_len;
>> > +};
>> 
>> This packs very poorly, and has a lot of padding holes.  Better ordering
>> would be:
>> 
>> struct nfp_net_tx_buf {
>> 	struct sk_buff *skb;
>> 	dma_addr_t dma_addr;
>> 	u32 real_len;
>> 	short int fidx;
>> 	u16 pkt_cnt;
>> };
> 
> Seems to pack fine on x86:
> 
> struct nfp_net_tx_buf {
>         struct sk_buff *           skb;                  /*     0     8 */
>         dma_addr_t                 dma_addr;             /*     8     8 */
>         short int                  fidx;                 /*    16     2 */
>         u16                        pkt_cnt;              /*    18     2 */
>         u32                        real_len;             /*    20     4 */
> 
>         /* size: 24, cachelines: 1, members: 5 */
>         /* last cacheline: 24 bytes */
> };
> 
> Are my packing skills deceiving me?  Maybe I'll try to build the driver
> for more esoteric architectures.

My bad, I misread the types.
