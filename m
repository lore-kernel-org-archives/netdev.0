From: jamal <hadi@cyberus.ca>
Subject: Re: XFRM_MSG_NEWAE
Date: Tue, 15 Aug 2006 06:02:04 -0400
Message-ID: <1155636124.6946.98.camel@jzny2>
References: <E1GCtxT-0000up-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:51392 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S965332AbWHOKCH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 06:02:07 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GCvkO-0007ey-EJ
	for netdev@vger.kernel.org; Tue, 15 Aug 2006 06:02:08 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GCtxT-0000up-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-15-08 at 18:07 +1000, Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> > 
> > I think we need a way to tone this down, so that if there are no truly
> > interested parties we don't do the km->notify work at all.
> 
> Actually, we do turn it off if nobody is listening, through
> xfrm_aevent_is_on().
> 

You can also adjust the default timers/packet counts (according to
Documentation/networking/xfrm_sync.txt):

a) /proc/sys/net/core/sysctl_xfrm_aevent_etime
used to provide default values for the XFRMA_ETIMER_THRESH in
incremental units of time of 100ms. The default is 10 (1 second)

b) /proc/sys/net/core/sysctl_xfrm_aevent_rseqth
used to provide default values for XFRMA_REPLAY_THRESH parameter
in incremental packet count. The default is two packets.

If you set either to 0 before starting ipsec, you should not see those
events being generated. You can also override the default values on a
per SA basis when adding/updating.

> > Also it would be nice to add xfrm mon support to print out these
> > messages properly if you haven't coded that up already :-)
> 
> Yes that would be good :)

I do have a few patches lined up. I was waiting for a sync with Stephen
with the current patchset i sent before submitting them (actually i will
wait until after him making a new release because there were just too
many patches i sent in the current update).

cheers,
jamal

