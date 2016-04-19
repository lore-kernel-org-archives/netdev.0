From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Tue, 19 Apr 2016 18:12:57 +0100
Message-ID: <57166719.4070209@solarflare.com>
References: <5716338E.4050003@solarflare.com>
 <5716347D.3030808@solarflare.com>
 <1461077434.10638.189.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S34ZFFFZVn2_ugp+eQg6QhdHj=CWPuvW3s9aC2dg75nqiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:15752 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754382AbcDSRNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 13:13:09 -0400
In-Reply-To: <CALx6S34ZFFFZVn2_ugp+eQg6QhdHj=CWPuvW3s9aC2dg75nqiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/16 16:46, Tom Herbert wrote:
> On Tue, Apr 19, 2016 at 7:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> We have hard time to deal with latencies already, and maintaining some
>> sanity in the stack(s)
> Right, this is significant complexity for a fairly narrow use case.
Why do you say the use case is narrow?  This approach should increase
packet rate for any (non-GROed) traffic, whether for local delivery or
forwarding.  If you're line-rate limited, it'll save CPU time instead.
The only reason I focused my testing on single-byte UDP is because the
benefits are more easily measured in that case.

If anything, the use case is broader than GRO, because GRO can't be used
for datagram protocols where packet boundaries must be maintained.
And because the listified processing is at least partly sharing code with
the regular stack, it's less complexity than GRO which has to have
essentially its own receive stack, _and_ code to coalesce the results
back into a superframe.

I think if we pushed bundled RX all the way up to the TCP layer, it might
potentially also be faster than GRO, because it avoids the work of
coalescing superframes; plus going through the GRO callbacks for each
packet could end up blowing icache in the same way the regular stack does.
If bundling did prove faster, we could then remove GRO, and overall
complexity would be _reduced_.

But I admit it may be a long shot.

-Ed
