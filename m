From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IGMP Unsolicited Report Interval too long for IGMPv3?
Date: Fri, 26 Jul 2013 17:06:51 +0200
Message-ID: <20130726150651.GD3890@order.stressinduktion.org>
References: <51ED998D.7000300@youview.com> <20130722211855.GL19643@kvack.org> <20130722215108.GG6538@order.stressinduktion.org> <20130725.164253.690113010547536005.davem@davemloft.net> <20130726131123.GC1281@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, william.manley@youview.com,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:41357 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757489Ab3GZPGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 11:06:52 -0400
Content-Disposition: inline
In-Reply-To: <20130726131123.GC1281@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 26, 2013 at 09:11:23AM -0400, Benjamin LaHaise wrote:
> On Thu, Jul 25, 2013 at 04:42:53PM -0700, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Mon, 22 Jul 2013 23:51:08 +0200
> > 
> > > On Mon, Jul 22, 2013 at 05:18:55PM -0400, Benjamin LaHaise wrote:
> > >> On Mon, Jul 22, 2013 at 09:43:57PM +0100, William Manley wrote:
> > >> > If an IGMP join packet is lost you will not receive data sent to the 
> > >> > multicast group so if no data arrives from that multicast group in a 
> > >> > period of time after the IGMP join a second IGMP join will be sent.  The 
> > >> > delay between joins is the "IGMP Unsolicited Report Interval".
> > >> > 
> > >> > In the kernel this seems to be hard coded to be chosen randomly between 
> > >> > 0-10s.  In our use-case (IPTV) this is too long as it can cause channel 
> > >> > change to be slow in the presence of packet loss.
> > >> > 
> > >> > I would guess that this 10s has come from IGMPv2 RFC2236, which was 
> > >> > reduced to 1s in IGMPv3 RFC3376.
> > >> 
> > >> Reducing the timeout does not solve the problem you are encountering, as 
> > >> any packet loss will still result in a 1 second delay.  I've encountered 
> > >> similar issues dealing with LCP Echo request/replies for keepalive 
> > >> messages on PPP sessions.  The correct approach is to queue the IGMP 
> > >> multicast join with a higher priority than other traffic in the system 
> > >> so that the requests are not lost due to congestion of a single queue.  
> > >> Sending packets with an 802.1p header might be appropriate in your 
> > >> use-case, or perhaps using higher priority internal queues.
> > > 
> > > Yes, we can do a little bit better. What do you think?
> > > 
> > > [PATCH net-next] ipv6: send igmpv3/mld packets with TC_PRIO_CONTROL
> > > 
> > > Reported-by: William Manley <william.manley@youview.com>
> > > Suggested-by: Benjamin LaHaise <bcrl@kvack.org>
> > > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > 
> > Ben, please give Hannes the feedback he is asking for.
> > 
> > Thanks.
> 
> I think Hannes' patch is good step in the right direction, so please add:
> Acked-by: Benjamin LaHaise <bcrl@kvack.org>

I just send a new patch with the priority changes for ipv4 included. I copied
your Acked-by, I hope this is ok.

Thanks,

  Hannes
