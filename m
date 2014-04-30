From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [3.15-rc3] Bisected: xen-netback mangles packets between two
 guests on a bridge since merge of "TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy" series.
Date: Wed, 30 Apr 2014 21:40:55 +0100
Message-ID: <53615FD7.8090803@citrix.com>
References: <395225650.20140430124506@eikelenboom.it> <1398871446.29914.163.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:26619 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759308AbaD3Uk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 16:40:59 -0400
In-Reply-To: <1398871446.29914.163.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/14 16:24, Eric Dumazet wrote:
> On Wed, 2014-04-30 at 12:45 +0200, Sander Eikelenboom wrote:
>
> This looks like skb->data_len is not properly set
>
> (Small note :
> alloc_page(GFP_ATOMIC|__GFP_COLD) should be a plain
> alloc_page(GFP_ATOMIC) : We prefer a page that has been used recently to
> avoid cache misses if possible.
> )
>
> This probably confuses skb_try_coalesce()
>
> My guess is xenvif_get_requests() forgets to init nskb->len /
> nskb->data_len for the skb that is attached to frag_list
xenvif_get_requests() calls alloc_skb() which inits these values to zero
>
> So the "skb->data_len += nskb->len;" at line 1353 is probably a nop.
