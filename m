From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: IGMP Unsolicited Report Interval too long for IGMPv3?
Date: Mon, 22 Jul 2013 17:18:55 -0400
Message-ID: <20130722211855.GL19643@kvack.org>
References: <51ED998D.7000300@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:45351 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932585Ab3GVVS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 17:18:58 -0400
Content-Disposition: inline
In-Reply-To: <51ED998D.7000300@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 22, 2013 at 09:43:57PM +0100, William Manley wrote:
> If an IGMP join packet is lost you will not receive data sent to the 
> multicast group so if no data arrives from that multicast group in a 
> period of time after the IGMP join a second IGMP join will be sent.  The 
> delay between joins is the "IGMP Unsolicited Report Interval".
> 
> In the kernel this seems to be hard coded to be chosen randomly between 
> 0-10s.  In our use-case (IPTV) this is too long as it can cause channel 
> change to be slow in the presence of packet loss.
> 
> I would guess that this 10s has come from IGMPv2 RFC2236, which was 
> reduced to 1s in IGMPv3 RFC3376.

Reducing the timeout does not solve the problem you are encountering, as 
any packet loss will still result in a 1 second delay.  I've encountered 
similar issues dealing with LCP Echo request/replies for keepalive 
messages on PPP sessions.  The correct approach is to queue the IGMP 
multicast join with a higher priority than other traffic in the system 
so that the requests are not lost due to congestion of a single queue.  
Sending packets with an 802.1p header might be appropriate in your 
use-case, or perhaps using higher priority internal queues.

		-ben

> There was a thread about this on linux-rdma in 2010 in the context of IP 
> over Infiniband but it seems no patches got applied as a result of the 
> discussion:
> 
> http://www.mail-archive.com/linux-rdma@vger.kernel.org/msg05740.html
> 
> Would the right patch reducing the unsolicited report interval for 
> IGMPv3 be acceptable now?
> 
> Thanks
> 
> Will
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
"Thought is the essence of where you are now."
