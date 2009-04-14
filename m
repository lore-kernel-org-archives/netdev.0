From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Kernel sends multicast groups to sockets that did not
	subscribe to the MC group
Date: Tue, 14 Apr 2009 09:25:51 -0400
Message-ID: <20090414132551.GC14305@hmsreliant.think-freely.org>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42198 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbZDNN1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 09:27:40 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904131704120.3517@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2009 at 05:06:08PM -0400, Christoph Lameter wrote:
> I ran two processes listening to two multicast groups:
> 
> One listening for 239.0.0.51 and the other on 239.0.0.50. Both are
> listening on the same port.
> 
> If I send a multicast message to 239.0.0.50 then both receive it. Why is
> the process listening to 239.0.0.51 receiving the multicast message send
> to 239.0.0.50?
> 
> 
Its correct behavior.  I had the same misunderstanding a few months back, but
Dave stevens set me right:
http://kerneltrap.org/index.php?q=mailarchive/linux-netdev/2008/7/11/2430904

Basically, its handled the exact same way that unicast addresses are handled,
its just a bit counter intuitive since group membership modifications are made
through a particular socket descriptor.  Despite that, multicast groups are
treated as being owned by the system, rather than by a socket.  So if you have a
situation in which you do a group membership add to 239.0.0.50 port 1024 on
socket A, and then do a bind on socket B to INADDR_ANY port 1024, you get those
multicast frames that socket A subscribed to.  Theres a link in the thread above
to a few papers that describe the operation in detail.

Regards
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
