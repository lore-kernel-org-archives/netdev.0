From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH iproute2 0/2] tc/cls_flower: Support for ip tunnel
 metadata set/release/classify
Date: Sun, 27 Nov 2016 12:35:23 +0200
Message-ID: <20161127103523.GA1808@office.localdomain>
References: <20161121102056.13468-1-amir@vadai.me>
 <20161124143856.43fa54d6@griffin>
 <20161124150633.GA27727@office.localdomain>
 <20161124163355.1c4d686f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:34678 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753586AbcK0Kf1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 05:35:27 -0500
Received: by mail-wj0-f194.google.com with SMTP id xy5so10533249wjc.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2016 02:35:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161124163355.1c4d686f@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 04:33:55PM +0100, Jiri Benc wrote:
> On Thu, 24 Nov 2016 17:06:33 +0200, Amir Vadai wrote:
> > So you mean to just unconditionally call skb_dst_drop() from
> > act_mirred()?
> 
> That's one option. Or just leave the dst there, it shouldn't matter?
> (Except for forwarding to a different tunnel but as I said, it's a
> corner case and we may have a "tunnel_key unset" action for that.)
Ok, so I will write in the docs that it is optional to use the "unset"
operation (and will rename it from "release" to "unset")

> 
> > The use case we already have that uses the release action is the
> > hardware offload support, which is already in the kernel.
> > It is using the "tunnel_key release" action to signal the hardware to
> > strip off the ip tunnel headers.
> 
> The tunnel headers must be removed upon reception on the tunnel
> interface without specifying anything, because that's how the Linux
> kernel behaves currently. If this is offloaded, this behavior must be
> preserved. I don't see how "tunnel_key release" might be used for
> stripping the headers.
Maybe I didn't express myself right: I need to tell the hardware
explicitly during the filter initialization to redirect the packets
arriving from one interface to another and to strip off the tunnel
headers. This is what happens when a "tunnel_key unset" action is
created and offloaded - it configures the hardware respectively.
So this is one usecase where this operation is needed - and yes, in this
use case the actual skb_dst_drop() is not important or needed, but I
don't think it makes any harm.
In the tunnel dev to tunnel dev use case, the operation could be
meaningful, if the user don't want to reuse the metadata created by the
origin tunnel dev.

> 
>  Jiri
