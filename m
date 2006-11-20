From: "Yang, Steve" <steve.yang@windriver.com>
Subject: RE: [patch] Performance enhancement patches for SB1250 MAC
Date: Mon, 20 Nov 2006 13:40:01 -0800
Message-ID: <F09F8223E8BE7D42BDA1800B19F3440D922017@ALA-MAIL03.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54951 "EHLO mail.wrs.com")
	by vger.kernel.org with ESMTP id S966582AbWKTVkP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Nov 2006 16:40:15 -0500
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

Sorry for responding late. 

1. I've submitted two patches, one for NAPI and the other for SKB_Cache.
They can go in individually. You've expressed objections to SKB_Cache.
What about the one for NAPI?

2. As for SKB_Cache patch, your concern about "maintenance" is valid.
However, the cost for allocating skb is not trivial for performance,
hence the patch. This is backed up by performance data measured. 20%
difference is a conservative number here.

Regards, 
Steve Yang

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org] 
Sent: Friday, October 13, 2006 1:25 PM
To: Yang, Steve
Cc: netdev@vger.kernel.org
Subject: Re: [patch] Performance enhancement patches for SB1250 MAC

On Thu, 12 Oct 2006 17:45:54 -0700
"Yang, Steve" <steve.yang@windriver.com> wrote:

> Stephen,
> 
> I assume the "expense" you referred to is the reserved SK cache
buffers.
> 
> 
> 1. The SKB_CACHE does hold on to buffers which would
>    otherwise be returned to the system (although the
>    number it holds on to is limited and configurable).
>    These buffers are only returned with certainty
>    at module unload time, although with normal traffic
>    most of them would be recycled pretty quick.  I think
>    the cache was implemented as a stack, rather than a
>    FIFO, which could cause a few buffers to be held for
>    quite a while under light loads.
> 
> 2. SKB_CACHE, just like NAPI, is also a configurable
>    option. Systems that need the performance have the
>    option of turning this on, at the expense of small
>    number of buffers; other systems which don't care
>    much about networking performance can leave this
>    option off.
> 
> 3. Can you elaborate other possible issues that you
>    touch upon (memory starvation/race, etc.)?
> 
> Regards,
> Steve Yang

Several drivers have tried to do this in the past, but the consensus has
been that this is a bad idea. 

Your code captures transmit skb's and uses them for receive. Why is this
a good idea? It is a maintenance nightmare, it breaks a lot of the
cleanup/initialization of skb's and means who ever changes something
like TSO has to go looking at some driver that is doing squirrley games.

Plus, your cache requires two extra lock round trips is seems.
The cost of alloc_skb should be trivial.
