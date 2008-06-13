From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] virtio: fix virtio_net xmit of freed skb bug
Date: Fri, 13 Jun 2008 15:57:02 -0400
Message-ID: <4852D10E.40001@garzik.org>
References: <200805261742.43215.rusty@rustcorp.com.au>	 <1211886386.3637.48.camel@muff>  <200805291634.18224.rusty@rustcorp.com.au> <1213366440.9507.0.camel@muff>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52855 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645AbYFMT5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 15:57:11 -0400
In-Reply-To: <1213366440.9507.0.camel@muff>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark McLoughlin wrote:
> On Thu, 2008-05-29 at 16:34 +1000, Rusty Russell wrote:
>> On Tuesday 27 May 2008 21:06:26 Mark McLoughlin wrote:
>>> On Mon, 2008-05-26 at 17:42 +1000, Rusty Russell wrote:
>>>> If we fail to transmit a packet, we assume the queue is full and put
>>>> the skb into last_xmit_skb.  However, if more space frees up before we
>>>> xmit it, we loop, and the result can be transmitting the same skb twice.
>>>>
>>>> Fix is simple: set skb to NULL if we've used it in some way, and check
>>>> before sending.
>> Great! It's a corner case, but it's no more complicated to do it your way.
>>
>> Minor mod, I find it clearer to have the vi->last_xmit_skb = NULL; under
>> the branch:
>>
>> Subject: [PATCH] virtio_net: Delay dropping tx skbs
>> Date: Tue, 27 May 2008 12:06:26 +0100
>> From: Mark McLoughlin <markmc@redhat.com>
>>
>> Currently we drop the skb in start_xmit() if we have a
>> queued buffer and fail to transmit it.
>>
>> However, if we delay dropping it until we've stopped the
>> queue and enabled the tx notification callback, then there
>> is a chance space might become available for it.
> 
> Hmm, we lost this one somewhere along the way ...

can someone resend?


