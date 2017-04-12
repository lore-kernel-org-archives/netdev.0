From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 1/3] bpf/wireless: add wifimon program type
Date: Wed, 12 Apr 2017 17:30:40 +0200
Message-ID: <1492011040.2855.18.camel@sipsolutions.net>
References: <20170412110726.9689-1-johannes@sipsolutions.net>
         <1492007254.2855.10.camel@sipsolutions.net>
         <20170412.111913.497795978751789475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, ast@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:38256 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753860AbdDLPa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 11:30:56 -0400
In-Reply-To: <20170412.111913.497795978751789475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 11:19 -0400, David Miller wrote:
> 
> > Instead it may make more sense to just have a "wifi_info(skb,
> info)"
> > function you can call, e.g. with a structure that has various
> fields
> > and flags to see which you care about.
> 
> I would advise against this, let the parsing part use __sk_buff and
> therefore have maximum flexibility.  You really cannot predict the
> future, so in my opinion it might be unwise to constrain at this
> point.

So my point with the wifi_info() function to call from the BPF program
was just that putting something that's not already in struct sk_buff
into __sk_buff doesn't really make a lot of sense - we still have to
actually build it somewhere/somehow without knowing if it's going to be
needed by the program. We already have things like prog->cb_access and
prog->dst_needed now, but I'm not sure we want to blow that up much.

At the same time, technically I *do* have the information in skb->cb,
but the format thereof is something I really wouldn't want to let
trickle into the ABI. Therefore, I think if somebody needs something
like the bitrate, we should have a wifi_info() function that can return
the bitrate (among other things) without having to pre-build the data.
We can still cache it in mac80211 if multiple programs are there, dunno
if that makes sense.

Nevertheless, I think if I don't use __sk_buff as the program argument
then things get really messy, so I'll stick to that, and avoid adding
anything to it as much as possible.

johannes
