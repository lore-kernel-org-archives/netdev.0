From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv5 net-next 0/6] xfrm: Add ESN support for AH
Date: Wed, 12 Feb 2014 13:06:04 +0100
Message-ID: <20140212120604.GA3438@secunet.com>
References: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38902 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751015AbaBLMGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 07:06:11 -0500
Content-Disposition: inline
In-Reply-To: <1390010068-15715-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 18, 2014 at 09:54:22AM +0800, Fan Du wrote:
> Hi,
> 
> This is initial Extended Sequence Number support for AH based on IPv4/6.
> The rationale is totally by the RFC 4302, which states:
> 
> 3.3.3.2.2.  Implicit Packet Padding and ESN
> 
>    If the ESN option is elected for an SA, then the high-order 32 bits
>    of the ESN must be included in the ICV computation.  For purposes of
>    ICV computation, these bits are appended (implicitly) immediately
>    after the end of the payload, and before any implicit packet padding.
> 
> So we attach the high-order 32bits as a scatterlist right after the packet
> payload to compute ICV value. 
> 
> Test:
> I add a knob in iproute2/ip/xfrm_state.c to enable esn when setting SA,
> which make it possible to test with-esn and without-esn scenarios, both
> cases works ok with ping using packetsize(-s) from default to 32768. 
> 
> v2:
>   - Patch3/5 and Patch4/5 add IPv6 part as requested by Steffen.
>   - Patch5/5 restrict ESN feature only to ESP and AH.
> v3:
>   - Fix double parens spotted by Sergei, and thanks for reporting.
> v4:
>   - Incorperate feedbacks from Steffen by simplify the code flow.
>   - Add Patch1/6 to introduce skb_to_sgvec_nomark
>   - Patch2/6 remove rebundant inclusion crypto/scatterwalk.h
> v5:
>   - Before calling type 'input' method, XFRM_SKB_CB(skb)->seq.input.hi
>     has already been set in network byte order in xfrm_input, so no
>     need to change the byte once in type 'input' method. So fix
>     Patch3/6 and Patch5/6.
> 
> 
> Fan Du (6):
>   skbuff: Introduce skb_to_sgvec_nomark to map skb without mark new end
>   {IPv4,xfrm} Add ESN support for AH egress part
>   {IPv4,xfrm} Add ESN support for AH ingress part
>   {IPv6,xfrm} Add ESN support for AH egress part
>   {IPv6,xfrm} Add ESN support for AH ingress part
>   xfrm: Don't prohibit AH from using ESN feature
> 

All applied to ipsec-next, thanks a lot for your work Fan!
