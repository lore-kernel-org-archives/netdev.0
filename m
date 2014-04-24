From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 1/3] net: ipv6: Unduplicate {raw,udp}v6_sendmsg code
Date: Thu, 24 Apr 2014 17:43:05 +0200
Message-ID: <20140424154305.GI1960@order.stressinduktion.org>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com> <1398235078-27088-1-git-send-email-lorenzo@google.com> <20140424150019.GE1960@order.stressinduktion.org> <20140424150206.GF1960@order.stressinduktion.org> <CAKD1Yr2DSkF59hdGyD=RiDNSseHT8u7Cf-0oYcJU=2uDgV_+Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37143 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758212AbaDXPnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:43:06 -0400
Content-Disposition: inline
In-Reply-To: <CAKD1Yr2DSkF59hdGyD=RiDNSseHT8u7Cf-0oYcJU=2uDgV_+Dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 25, 2014 at 12:13:57AM +0900, Lorenzo Colitti wrote:
> On Fri, Apr 25, 2014 at 12:02 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > > I am afraid we could jump to do_append_data without having dontfrag
> > > initialized. The jump happens before we call to ip6_datagram_send_common.
> > >
> > > So the initialization of dontfrag to -1 needs to be added to the caller.
> >
> > Also see e36d3ff91130002 (udp6: respect IPV6_DONTFRAG sockopt in case there
> > are pending frames) which was a bug we had some time ago.
> 
> Hmm. So I'm the second person to trip over that goto. It doesn't help
> that the compiler didn't notice that it could have been used
> uninitialized.
> 
> I wonder, is it better to just initialize dontfrag to np->dontfrag
> instead of -1 in the caller? ip6_datagram_send_ctl seems to just
> overwrite dontfrag with whatever comes from userspace, so nobody ever
> checks that it's < 0.

Yes, that is what I had in mind. So we must not reset dontfrag to -1 in
datagram_common_send and leave the check just after do_append_data as is.

Bye,

  Hannes
