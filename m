From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: RE: [PATCH] be2net: Bugfix for packet drop with kernel param
 swiotlb=force
Date: Fri, 21 Feb 2014 07:15:47 +0000
Message-ID: <07309948-80e6-4274-80a2-053f0ba65643@CMEXHTCAS1.ad.emulex.com>
References: <e57b63ae-b1a8-47f3-8f2b-71cb6d8ab4fc@CMEXHTCAS1.ad.emulex.com>
 <OF23C58A81.24C211B9-ON48257C86.0025CED7-48257C86.0026D02E@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>,
	"wang.liang82@zte.com.cn" <wang.liang82@zte.com.cn>,
	"cai.qu@zte.com.cn" <cai.qu@zte.com.cn>,
	"li.fengmao@zte.com.cn" <li.fengmao@zte.com.cn>,
	"long.chun@zte.com.cn" <long.chun@zte.com.cn>,
	David Miller <davem@davemloft.net>
To: "jiang.biao2@zte.com.cn" <jiang.biao2@zte.com.cn>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:47654 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbaBUHPx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 02:15:53 -0500
In-Reply-To: <OF23C58A81.24C211B9-ON48257C86.0025CED7-48257C86.0026D02E@zte.com.cn>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: jiang.biao2@zte.com.cn [mailto:jiang.biao2@zte.com.cn]
> 
> > >
> > > From: Li Fengmao <li.fengmao@zte.com.cn>
> > >
> > > There will be packet drop with kernel param "swiotlb = force" on
> > > Emulex 10Gb NIC using be2net driver. The problem is caused by
> > > receiving skb without calling pci_unmap_page() in get_rx_page_info().
> > > rx_page_info->last_page_user is initialized to false in
> > > be_post_rx_frags() when current frag are mapped in the first half of
> > > the same page with another frag. But in that case with
> > > "swiotlb = force" param, data can not be copied into the page of
> > > rx_page_info without calling pci_unmap_page, so the data frag mapped
> > > in the first half of the page will be dropped.
> > >
> > > It can be solved by creating only a mapping relation between frag
> > > and page, and deleting rx_page_info->last_page_user to ensure
> > > calling pci_unmap_page when handling each receiving frag.
> >
> > This patch uses an entire page for each RX frag (whose default size is 2048).
> > Consequently, on platforms like ppc64 where the default PAGE_SIZE is 64K,
> > memory usage becomes very inefficient.
> >
> > Instead, I've tried a partial-page mapping scheme. This retains the
> > page sharing logic, but un-maps each frag separately so that
> > the data is copied from the bounce buffers.
> >
> > Pls see if this works for you;  thanks.
> >
> Our patch indeed has some problem because use an entire page by alloc_pages，
> maybe kmalloc should be appropriate.
> Your modification works for us, it should be a right patch for the bug.

Thanks for verifying. I'll re-post my patch with a proper sign-off.

-Sathya
