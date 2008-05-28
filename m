From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 18:20:02 +0300
Message-ID: <200805281820.02143.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <200805281620.55578.opurdila@ixiacom.com> <20080528141104.GA5543@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:3692 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752479AbYE1PVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 11:21:13 -0400
In-Reply-To: <20080528141104.GA5543@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 May 2008, Evgeniy Polyakov wrote:

> > > I preserved old semantic, when we free skb
> > > only if we read it whole or in case of fin. With your changes we can
> > > also free skb, if it was partially consumed
> >
> > If the skb was partially consumed then tcp_recv_skb(seq-1) will return
> > the same skb and the offset +1 != skb->len, thus we will not free it.
>
> I understand now, please correct me if I got your idea wrong.
> We only ned to search for the skb again only in case we processed it and
> it was possible that socket lock was dropped. So, the only needed place
> to put tcp_recv_skb() is where you pointed. Next, to find current skb we
<snip>

Yes, that is correct. 

> So yes, your patch is simpler and faster than mine so you should push it
> upstream. Fortunately David Miller is in copy and will (David, will
> you?) pick it up and push, likely it is also needed for stable?
>

OK, will clean it up and post a proper patch soon. Which tree should I base it 
on?

Thanks,
tavi
