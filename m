From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [RFC PATCH 3/8] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Wed, 20 Feb 2008 17:30:43 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802201730240.26109@fbirervta.pbzchgretzou.qr>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <Pine.LNX.4.64.0802201651580.26109@fbirervta.pbzchgretzou.qr>
 <47BC54FB.2050508@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:53604 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933335AbYBTQao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 11:30:44 -0500
In-Reply-To: <47BC54FB.2050508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Feb 20 2008 17:27, Patrick McHardy wrote:
>> Striking. How can this even happen? A callsite which calls
>> 
>>  dev_alloc_skb(n)
>> 
>> is just equivalent to
>> 
>>  __dev_alloc_skb(n, GFP_ATOMIC);
>> 
>> which means there's like 4 (or 8 if it's long) bytes more on the
>> stack. For a worst case, count in another 8 bytes for push and pop or mov on
>> the stack. But that still does not add up to 23 kb.
>
> __dev_alloc_skb() is also an inline function which performs
> some extra work. Which raises the question - if dev_alloc_skb()
> is uninlined, shouldn't __dev_alloc_skb() be uninline as well?
>
I'd like to see the results when {__dev_alloc_skb is externed
and dev_alloc_skb remains inlined}.
