From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: fix infinite loop in __skb_recv_datagram()
Date: Fri, 15 Feb 2013 13:41:41 +0100
Message-ID: <20130215124141.GB20018@order.stressinduktion.org>
References: <1360638903.20362.32.camel@edumazet-glaptop> <CA+ydwtoBttwiVz+oy0hnetUTQMi7XHyS9bfGzjuP1L41srBk=g@mail.gmail.com> <1360685813.13993.12.camel@edumazet-glaptop> <20130212.160733.2235089567079483883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, tt.rantala@gmail.com,
	netdev@vger.kernel.org, davej@redhat.com, xemul@parallels.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37180 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab3BOMlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 07:41:42 -0500
Content-Disposition: inline
In-Reply-To: <20130212.160733.2235089567079483883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2013 at 04:07:33PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 12 Feb 2013 08:16:53 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Tommi was fuzzing with trinity and reported the following problem :
> > 
> > commit 3f518bf745 (datagram: Add offset argument to __skb_recv_datagram)
> > missed that a raw socket receive queue can contain skbs with no payload.
> > 
> > We can loop in __skb_recv_datagram() with MSG_PEEK mode, because
> > wait_for_packet() is not prepared to skip these skbs.
>  ...
> > Reported-by: Tommi Rantala <tt.rantala@gmail.com>
> > Tested-by: Tommi Rantala <tt.rantala@gmail.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied, thanks.

This issue got a CVE: http://seclists.org/oss-sec/2013/q1/310
Perhaps it's something that should go to stable?

Thanks,

  Hannes
