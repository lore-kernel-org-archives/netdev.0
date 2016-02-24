From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Wed, 24 Feb 2016 14:46:01 +0900
Message-ID: <20160224054557.GA12134@vergenet.net>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
 <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
 <56CC5F73.9080201@iogearbox.net>
 <56CC6F3E.6000106@mojatatu.com>
 <56CC84F2.8030909@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	dj@verizon.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36704 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbcBXFqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 00:46:11 -0500
Received: by mail-pf0-f170.google.com with SMTP id e127so6477769pfe.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 21:46:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56CC84F2.8030909@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 05:12:34PM +0100, Daniel Borkmann wrote:
> On 02/23/2016 03:39 PM, Jamal Hadi Salim wrote:
> >On 16-02-23 08:32 AM, Daniel Borkmann wrote:
> >>On 02/23/2016 01:49 PM, Jamal Hadi Salim wrote:
> >>>From: Jamal Hadi Salim <jhs@mojatatu.com>
> >>>
> >>>This action allows for a sending side to encapsulate arbitrary metadata
> >>>which is decapsulated by the receiving end.
> >>>The sender runs in encoding mode and the receiver in decode mode.
> >>>Both sender and receiver must specify the same ethertype.
> >>>At some point we hope to have a registered ethertype and we'll
> >>>then provide a default so the user doesnt have to specify it.
> >>>For now we enforce the user specify it.
> >>>
> >>>Lets show example usage where we encode icmp from a sender towards
> >>>a receiver with an skbmark of 17; both sender and receiver use
> >>>ethertype of 0xdead to interop.
> >>
> >>On a conceptual level, as this is an L2 encap with TLVs, why not having
> >>a normal device driver for this like we have in other cases that would
> >>encode/decode the meta data itself?
> >
> >netdevs dont scale for large number of policies. See why ipsec which
> >at one point was implemented using a netdev and why xfrm eventually
> >was chosen as the way forward. Or look at the recent lwt
> >effort.
> 
> Sure, I'm just saying that it could conceptionally be similar to the
> collect metadata idea just on L2 in your case. The encoding/decoding
> and transport of the information is actually not overly tc specific
> at least from the code that's shown so far, just a thought.

>From my point of view the test should be weather the encapsulation might
reasonably be expected to be used outside of the context of tc. If so then
it makes sense to use a netdev to allow sharing of infrastructure between
different kernel components.

I suspect the answer to that question is no and thus IMHO a netdev would be
nice to have rather than compelling.

With regards to overhead of netdevs: I think that could be mitigated to
some extent by using LWT or some other metadata-based approach to allow a
single netdev to be use by multiple tc action instances.

[snip]
