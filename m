From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Fri, 19 May 2017 15:21:49 +0100
Message-ID: <7402a02c-cb00-d48e-1d2a-ccb03356fb72@solarflare.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
 <97910214-213c-c5c6-4a02-adc16cd836aa@fb.com>
 <c8e4ce49-5707-3d6d-c8c2-80dd8335d981@solarflare.com>
 <739ef342-728c-de57-c2a2-03fa85b3a246@solarflare.com>
 <17a1c4a2-68d7-0f8f-f009-b97706d67ceb@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:40069 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750749AbdESOWF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 10:22:05 -0400
In-Reply-To: <17a1c4a2-68d7-0f8f-f009-b97706d67ceb@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/05/17 02:22, Alexei Starovoitov wrote:
> In your .py I'd only change __str__(self) to print them in mask,value
> as the order they're passed into constructor to make it easier to read. 
Actually I was going to go the other way and change the ctor to take
 value,mask.  But I agree they're inconsistent right now.

> this mul algo I don't completely understand. It feels correct,
> but I'm not sure we really need it for the kernel. 
You're probably right; I was just driven by a completionist desire to
 cover everything I could.

> What I love about the whole thing that it works for access into
> packet, access into map values and in the future for any other
> variable length access.
Sure, but don't start thinking it subsumes all the other checks.  We
 will still need e.g. max/min tracking, because packet length isn't
 always a power of 2.

> Are you planning to work on the kernel patch for this algo?
> Once we have it the verifier will be smarter regarding
> alignment tracking than any compiler i know :) 
I'm currently translating the algos to C.  But for the kernel patch,
 I'll need to read & understand the existing verifier code, so it
 might take a while :)  (I don't suppose there's any design document
 or hacking-notes you could point me at?)
But I'll give it a go for sure.

-Ed
