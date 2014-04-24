From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 1/3] net: ipv6: Unduplicate {raw,udp}v6_sendmsg code
Date: Thu, 24 Apr 2014 17:02:06 +0200
Message-ID: <20140424150206.GF1960@order.stressinduktion.org>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com> <1398235078-27088-1-git-send-email-lorenzo@google.com> <20140424150019.GE1960@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37026 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756799AbaDXPCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:02:07 -0400
Content-Disposition: inline
In-Reply-To: <20140424150019.GE1960@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 24, 2014 at 05:00:19PM +0200, Hannes Frederic Sowa wrote:
> On Wed, Apr 23, 2014 at 03:37:56PM +0900, Lorenzo Colitti wrote:
> >  	if (msg->msg_flags&MSG_CONFIRM)
> >  		goto do_confirm;
> > @@ -1262,8 +1164,6 @@ back_from_confirm:
> >  	up->pending = AF_INET6;
> >  
> >  do_append_data:
> > -	if (dontfrag < 0)
> > -		dontfrag = np->dontfrag;
> 
> I am afraid we could jump to do_append_data without having dontfrag
> initialized. The jump happens before we call to ip6_datagram_send_common.
> 
> So the initialization of dontfrag to -1 needs to be added to the caller.

Also see e36d3ff91130002 (udp6: respect IPV6_DONTFRAG sockopt in case there
are pending frames) which was a bug we had some time ago.

Bye,

  Hannes
