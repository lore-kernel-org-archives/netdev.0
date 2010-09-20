From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Mon, 20 Sep 2010 07:21:49 +0000
Message-ID: <20100920072149.GA6353@ff.dom.local>
References: <1283852248.2338.160.camel@edumazet-laptop> <20100910.125449.235704956.davem@davemloft.net> <20100911123140.GA1939@del.dom.local> <20100919.171725.245378386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37716 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848Ab0ITHVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 03:21:55 -0400
Received: by bwz11 with SMTP id 11so4048409bwz.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 00:21:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100919.171725.245378386.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 19, 2010 at 05:17:25PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 11 Sep 2010 14:31:40 +0200
> 
> > Otherwise seems OK, but I still would like to know the scenario
> > demanding this change.
> 
> Ok Jarek, after some more consideration I agree with you.
> Removing this kind of sharing would be unwise, ho hum...
> 
> While pondering over this I thought about why we even need
> frag lists at all.  We need them for two reasons:
> 
> 1) Because we have an inability to turn kmalloc data references into
>    page based ones easily.
> 
>    We've run into this sort of problem with socket splice() too.
> 
> 2) For recording the segmentation points of a fragmented packet.
> 
> We definitely don't use frag lists for performance, if you look
> in the GRO history the GRO code specifically has been changed
> to prefer accumulating into the page vector whenever possible
> because using frag lists is a lot slower.

Yes, and GRO made frag lists more popular btw.

> Anyways, even if we somehow solved #1 we'd still have a lot of
> code (even bluetooth) using it for the sake of issue #2.

Since there exist drivers using entirely paged skbs and napi_gro_frags
path I can't see why #1 or #2 could be unsolvable elsewhere.

> So for the time being there is no clear path for trying to
> eliminate frag lists altogether if we wanted to do that either.

Probably we could start from enhacing moving drivers to paged skbs
where possible. And maybe simplifying the skb model by not allowing
frags and frag lists together?

Btw, I wonder what is the exact reason we can't use only
NET_SKBUFF_DATA_USES_OFFSET?

Jarek P.
