From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and el bits)
Date: Wed, 23 May 2007 23:13:29 -0500
Message-ID: <432a3d01f7b2630b5de24686160539fd@bga.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com> <53c44b6f03973eb1b28f221859d3002c@bga.com> <465369AF.8080508@roinet.com> <f83441453b1233771c5bda869912aeca@bga.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, e1000-devel@lists.sourceforge.net,
	David Acker <dacker@roinet.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.realtime.net ([205.238.132.86]:53531 "EHLO
	ruth.realtime.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758180AbXEXERF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 00:17:05 -0400
In-Reply-To: <f83441453b1233771c5bda869912aeca@bga.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok pointed out I had left an unfinished thought this
morning ... well, here's a completion, but I will mostly
think about David's latest proposal.

I think I was debating proposing this, then got side
tracked then hit send.

On May 23, 2007, at 9:02 AM, Milton Miller wrote:
>
>> What if we just fixed the alignment of rfd to make sure it is cache 
>> aligned?  Then we know our syncs will be a single cache flush.
>
> That doesn't help in the coherent dma case; the device can still
> read in between, and we need to handle the !EL size 0 case.
>
> Actually, I thought about it some more after yesterdays note.
> We can set the size !0 after making sure the device sees EL
> (wmb and pci_sync_for_device), as long as we remember this
> buffer used to be size 0 when doing RX clean, and look ahead
> for another complete packet as long as the size was ever 0.
>
> My proposal was just to use "size is still 0" as that flag,
> wasting the space allocated for that skb.
>
> Another aproach is to always allocate a rfd-only packet
> at the beginning of the loop, and inserting th


... inserting this dummy skb before the last successfuly
allocated one, moving the links around.   This has the
benefit of not allocating a 1500+32 byte buffer that we
don't intend to fill, but is a lot more complicated
insert and move skb around when filling.

We now return you to your previously scheduled program.

Now back to thinking about David's proposal, and my thoughts
about how I might do the allocate non-zero size.

milton

