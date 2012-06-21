From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Thu, 21 Jun 2012 07:07:06 +0200
Message-ID: <1340255226.4604.3774.camel@edumazet-glaptop>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>
	 <1340170590.4604.784.camel@edumazet-glaptop>
	 <1340180223.4604.828.camel@edumazet-glaptop>
	 <1340198514.4604.970.camel@edumazet-glaptop>  <4FE29DE4.1010705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:32872 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270Ab2FUFHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 01:07:11 -0400
Received: by wgbds11 with SMTP id ds11so4248492wgb.1
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2012 22:07:10 -0700 (PDT)
In-Reply-To: <4FE29DE4.1010705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-20 at 21:07 -0700, Alexander Duyck wrote:
> On 6/20/2012 6:21 AM, Eric Dumazet wrote:

> > +		nc->page = alloc_pages(GFP_ATOMIC | __GFP_COLD |
> > +				       (NETDEV_FRAG_ORDER ? __GFP_COMP : 0),
> > +				       NETDEV_FRAG_ORDER);

> I was wondering if you needed the check for NETDEV_FRAG_ORDER here.  
>  From what I can tell setting __GFP_COMP for an order 0 page has no 
> effect since it only seems to get checked in prep_new_page and that is 
> after a check to verify if the page is order 0 or not.

Good point, it seems some net drivers could be changed to remove
useless tests.

I'll post some performance data as well.
