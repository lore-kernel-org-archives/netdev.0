From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: AF_PACKET mmap() v4...
Date: Thu, 05 Nov 2015 03:38:36 -0800
Message-ID: <1446723516.4184.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151105.000414.1682124328670738318.davem@davemloft.net>
	 <4931220.z2MFa8LzkQ@wuerfel> <563B23C3.5070406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33287 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031425AbbKELii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 06:38:38 -0500
Received: by pabfh17 with SMTP id fh17so85711983pab.0
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2015 03:38:38 -0800 (PST)
In-Reply-To: <563B23C3.5070406@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-11-05 at 10:39 +0100, Daniel Borkmann wrote:
> On 11/05/2015 10:07 AM, Arnd Bergmann wrote:
> > On Thursday 05 November 2015 00:04:14 David Miller wrote:
> >> As part of fixing y2038 problems, Arnd is going to have to make a new
> >> version fo the AF_PACKET mmap() tpacker descriptors in order to extend
> >> the time values to 64-bit.
> >>
> >> So I want everyone to think about whether there are any other changes
> >> we might want to make given that we have to make a v4 anyways.
> >>
> >> Particularly, I am rather certain that the buffer management could be
> >> improved.  Some have complained that v3 is kinda awkward to use and/or
> >> suboptimal is various ways.
> >
> > I have taken a closer look at the actual timestamp data now, and noticed
> > that we use __u32 for both tp_sec and ts_sec in the user visible data.
> > This means that once we fix the internal implementation to use 64-bit
> > timestamps, we actually won't overflow until 2106 because the 2038 overflow
> > is only for signed 32-bit numbers as we have in 'struct timespec'.
> >
> > So the good news is that we can keep the existing v1 through v3 formats
> > beyond 2038, but only as long as all user space that cares about the
> > value also interprets it as unsigned.
> 
> Right, I was just about to ask that. So we could just make a union in
> AF_PACKET's UAPI for a single 64-bit variable (as in ktime_t) to fix that.

If I am not mistaken, af_packet also lacks the ability to properly set
skb->protocol

I noticed this using trafgen on a bonding device, when I did my SYNFLOOD
tests for TCP listener rewrite.

The bonding hash function might uses flow dissector, but as this flow
dissection depends on skb->protocol, all the traffic is directed on a
single slave.

 
