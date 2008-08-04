From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Mon, 4 Aug 2008 23:03:33 +0200
Message-ID: <20080804210333.GA2849@ami.dom.local>
References: <20080731171431.GA9464@ami.dom.local> <4892AA16.40706@trash.net> <20080801101929.GA12735@ff.dom.local> <20080803.182524.240976246.davem@davemloft.net> <20080804062813.GA4570@ff.dom.local> <20080804213535.14214iqhxkx3v3so@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:30521 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764776AbYHDVD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 17:03:59 -0400
Received: by ug-out-1314.google.com with SMTP id h2so2693ugf.16
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 14:03:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080804213535.14214iqhxkx3v3so@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 09:35:35PM +0300, Jussi Kivilinna wrote:
> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>
>>
>> These 2 patches aren't supposed to fix these problems:
>>
>> - the __NET_XMIT_STOLEN patch fixes a problem when a qdiscs passed
>>   upwards NET_XMIT_SUCCESS when eg. an skb was stolen by an action,
>>   to prevent treating this as dropped; then the upper qdiscs couldn't
>>   tell it's not the full NET_XMIT_SUCCESS and counted it as queued,
>>   which was wrong. (BTW, I especially tried to do it with minimal
>>   changes in htb_enqueue() to let you apply your htb patch without
>>   much editing.)
>>
>> - the __NET_XMIT_BYPASS actually doesn't fix any serious problem, but
>>   lets to remove the mapping from dev_queue_xmit(), and BTW it passes
>>   better information to upper qdiscs too.
>>
>
> This seems to also make sure that when returning 'full'  
> NET_XMIT_SUCCESS, skb pointer is safe(r?) to use now.

I guess so... At least theoretically - I was mainly afraid of
redirecting, which isn't fully implemented yet. On the other hand,
outwards of qdiscs there is still no difference.

Jarek P.
