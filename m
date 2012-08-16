From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 001/001] smsc95xx: Fix hard_header_len
Date: Thu, 16 Aug 2012 18:59:33 +0100
Message-ID: <1345139973.2832.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345060138-5629-1-git-send-email-jimbob.betts@googlemail.com>
	 <CAKh2mn4pK-8=OVkahSZ8VWpX9Va=qCDQUdOONK1FZ75Fbk0Mdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: JamesBetts <jimbob.betts@googlemail.com>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Steve Glendinning <steve@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52193 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932814Ab2HPR7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 13:59:39 -0400
In-Reply-To: <CAKh2mn4pK-8=OVkahSZ8VWpX9Va=qCDQUdOONK1FZ75Fbk0Mdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-16 at 10:57 +0100, Steve Glendinning wrote:
> Hi James,
> 
> Thanks for spotting this, I don't think I've ever tested this device with IMQ.
> 
> > -       dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
> > -       dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
> > +       dev->net->needed_headroom = SMSC95XX_TX_OVERHEAD_CSUM;
> > +       dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len +
> > dev->net->needed_headroom;
> 
> I'm unsure what we *should* be setting hard_header_len and
> needed_headroom to.  David?

hard_header_len is set to ETH_HLEN by alloc_etherdev() (in the
ether_setup() callback).  Any extra headroom you want before the
Ethernet header should indeed be specified in needed_headroom.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
