From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch] Performance enhancement patches for SB1250 MAC
Date: Fri, 13 Oct 2006 13:24:58 -0700
Message-ID: <20061013132458.339afbe6@freekitty>
References: <D9055C0A0A86BD4E89AD96A89EA767DBA6AFBC@ALA-MAIL03.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25817 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932084AbWJMVfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 17:35:16 -0400
To: "Yang, Steve" <steve.yang@windriver.com>
In-Reply-To: <D9055C0A0A86BD4E89AD96A89EA767DBA6AFBC@ALA-MAIL03.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Oct 2006 17:45:54 -0700
"Yang, Steve" <steve.yang@windriver.com> wrote:

> Stephen,
> 
> I assume the "expense" you referred to is the reserved SK cache buffers.
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

Several drivers have tried to do this in the past, but the consensus
has been that this is a bad idea. 

Your code captures transmit skb's and uses them for receive. Why is
this a good idea? It is a maintenance nightmare, it breaks a lot of
the cleanup/initialization of skb's and means who ever changes something
like TSO has to go looking at some driver that is doing squirrley games.

Plus, your cache requires two extra lock round trips is seems.
The cost of alloc_skb should be trivial.
