From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next 4/6] 6lowpan: fix
 fragmentation
Date: Wed, 14 May 2014 18:06:10 +0200
Message-ID: <20140514180610.31293ff0@zoidberg>
References: <1400082191-16493-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1400082191-16493-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<20140514155503.GA14689@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:45625 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755199AbaENQGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 12:06:25 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4EG6Nfj023263
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 14 May 2014 18:06:24 +0200
In-Reply-To: <20140514155503.GA14689@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 May 2014 17:56:57 +0200
Alexander Aring <alex.aring@gmail.com> wrote:

> > +
> > +	frag = alloc_skb(real_dev->hard_header_len +
> > +			 real_dev->needed_tailroom + size,
> > +			 GFP_ATOMIC);
> 
> Why not keep netdev_alloc_skb for the real_dev?
> 
> But then we need to use dev_kfree_skb.

Because netdev_alloc_skb allocates "for RX", which uses different
allocation flags internally and might do the wrong thing when memory
is tight.

Also, all skb free funtions are essentially the same, where
dev_kfree_skb == kfree_skb by a macro definition, and what remains
differs pretty much only in how it shows up in traces. They all call
__kfree_skb internally.

> 
> - Alex
