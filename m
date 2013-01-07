From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xen/netfront: improve truesize tracking
Date: Mon, 07 Jan 2013 07:26:39 -0800
Message-ID: <1357572399.6919.3047.camel@edumazet-glaptop>
References: <1355838711-5473-1-git-send-email-ian.campbell@citrix.com>
	 <1355843525.9380.18.camel@edumazet-glaptop>
	 <1355844398.14620.254.camel@zakaz.uk.xensource.com>
	 <55633610.20121219123427@eikelenboom.it>
	 <1355933869.21834.13.camel@edumazet-glaptop>
	 <1797374383.20121220135139@eikelenboom.it>
	 <1356017968.21834.2859.camel@edumazet-glaptop>
	 <1609010645.20121221122100@eikelenboom.it> <50D4AB87.8050601@hp.com>
	 <561084196.20130103214030@eikelenboom.it>
	 <1357566063.7989.68.camel@zakaz.uk.xensource.com>
	 <606842712.20130107151133@eikelenboom.it>
	 <1357568565.7989.96.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	annie li <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:33797 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab3AGP0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 10:26:42 -0500
Received: by mail-pb0-f50.google.com with SMTP id wz7so10649388pbc.37
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 07:26:42 -0800 (PST)
In-Reply-To: <1357568565.7989.96.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 14:22 +0000, Ian Campbell wrote:
> On Mon, 2013-01-07 at 14:11 +0000, Sander Eikelenboom wrote:
> one is buggy.
> > 
> > Will see if i can run against that as well, although i thought Eric
> > said to prefer the "skb->truesize += PAGE_SIZE *
> > skb_shinfo(skb)->nr_frags;"
> 
> Right, I meant to compare "PAGE_SIZE * skb_shinfo(skb)->nr_frags" vs
> "skb->data_len - NETFRONT_SKB_CB(skb)->pull_to". TBH I trust Eric so I'm
> inclined to just go with what he suggests.

This is the more precise estimation, and it appears to not bring obvious
performance regression, so I definitely would favor this one ;)
