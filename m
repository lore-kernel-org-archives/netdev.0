From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Wed, 17 May 2017 18:00:03 +0100
Message-ID: <fae2fc09-d26e-213a-cd9d-1699db691515@solarflare.com>
References: <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <20170517.121313.1437427582437926345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>,
        <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:42778 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932150AbdEQRAV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 13:00:21 -0400
In-Reply-To: <20170517.121313.1437427582437926345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/05/17 17:13, David Miller wrote:
> Both cases are common in real BPF programs.  The offsets really are
> necessary.  It's funny because initially I tried to implement this
> without the auxiliary offset and it simply doesn't work. :-)
> 
> We always have to track when you've seen the offset that cancels out
> the NET_IP_ALIGN.  And as stated it can occur both before and after
> variable offsets have been introduced.
> 
> You have to catch both:
> 
> 	ptr += variable;
> 	ptr += 14;
> 
> and:
> 
> 	ptr += 14;
> 	ptr += variable; /* align = 4 */
> 
> And always see at the end that "NET_IP_ALIGN + offsets" will
> be properly 4 byte aligned.

Did you see the algorithms I posted with two masks?  Effectively they
 are tracking the 'quotient' and 'remainder', but in a was that might
 be easier to manipulate (bit-twiddly etc.) than the aux offset.  I
 think they handle both the above cases, in a nicely general way.

-Ed
