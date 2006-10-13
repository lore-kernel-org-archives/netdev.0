From: "Yang, Steve" <steve.yang@windriver.com>
Subject: FW: [patch] Performance enhancement patches for SB1250 MAC
Date: Thu, 12 Oct 2006 17:48:26 -0700
Message-ID: <D9055C0A0A86BD4E89AD96A89EA767DBA6AFBD@ALA-MAIL03.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:3727 "EHLO mail.wrs.com")
	by vger.kernel.org with ESMTP id S1751387AbWJMAs1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 20:48:27 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.3) with ESMTP id k9D0mR5p007564
	for <netdev@vger.kernel.org>; Thu, 12 Oct 2006 17:48:27 -0700 (PDT)
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----Original Message-----
From: Yang, Steve 
Sent: Thursday, October 12, 2006 5:46 PM
To: 'Stephen Hemminger'
Cc: netdev@vger.kernel.org
Subject: RE: [patch] Performance enhancement patches for SB1250 MAC

Stephen,

I assume the "expense" you referred to is the reserved SK cache buffers.


1. The SKB_CACHE does hold on to buffers which would
   otherwise be returned to the system (although the
   number it holds on to is limited and configurable).
   These buffers are only returned with certainty
   at module unload time, although with normal traffic
   most of them would be recycled pretty quick.  I think
   the cache was implemented as a stack, rather than a
   FIFO, which could cause a few buffers to be held for
   quite a while under light loads.

2. SKB_CACHE, just like NAPI, is also a configurable
   option. Systems that need the performance have the
   option of turning this on, at the expense of small
   number of buffers; other systems which don't care
   much about networking performance can leave this
   option off.

3. Can you elaborate other possible issues that you
   touch upon (memory starvation/race, etc.)?

Regards,
Steve Yang


-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@osdl.org] 
Sent: Thursday, October 12, 2006 3:14 PM
To: Yang, Steve
Cc: netdev@vger.kernel.org
Subject: Re: [patch] Performance enhancement patches for SB1250 MAC

On Thu, 12 Oct 2006 14:54:33 -0700
"Yang, Steve" <steve.yang@windriver.com> wrote:

> FYI ...
> 
> Regards,
> Steve Yang
> 
> -----Original Message-----
> From: Yang, Steve
> Sent: Monday, September 25, 2006 3:50 PM
> To: 'linux-mips@linux-mips.org'
> Cc: 'ralf@linux-mips.org'; 'Mark E Mason'
> Subject: Performance enhancement patches for SB1250 MAC
> 
> Hi,
> 
> The attached are two network performance enhancement patches for 
> SB1250 MAC. The NAPI patch applies first. Followed by the "skb cache"
patch.
> They applied and builds cleanly on 2.6.18 kernel for the following 
> kernel option combinations:
> 
> SBMAC_NAPI	no	yes	yes
> SKB_CACHE	no	no	yes
>  
> Regards,
> Steve Yang
> 

NAK on the SKB_CACHE it is idea that just ends up favoring your driver
at the expense of the rest of the system. Also, there are
resource/memory starvation issues and probably other races as well.

I bet it makes your benchmark run faster, but it doesn't belong in
normal kernel

--
Stephen Hemminger <shemminger@osdl.org>
