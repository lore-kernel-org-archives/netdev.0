From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 11:15:04 -0400
Message-ID: <20090416151504.GA28978@hmsreliant.think-freely.org>
References: <alpine.DEB.1.10.0904161035390.19650@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, dlstevens@us.ibm.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48640 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601AbZDPPPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 11:15:09 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0904161035390.19650@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 16, 2009 at 10:38:23AM -0400, Christoph Lameter wrote:
> Do what David Stevens suggest: Add a per socket option
> 
> 
> 
> Subject: Multicast: Filter Multicast traffic per socket mc_list
> 
> If two processes open the same port as a multicast socket and then
> join two different multicast groups then traffic for both multicast groups
> is forwarded to either process. This means that application will get surprising
> data that they did not ask for. Applications will have to filter these out in
> order to work correctly if multiple apps run on the same system.
> 
> These are pretty strange semantics but they have been around since the
> beginning of multicast support on Unix systems. Most of the other operating
> systems supporting Multicast have since changed to only supplying multicast
> traffic to a socket that was selected through multicast join operations.
> 
> This patch does change Linux to behave in the same way. But there may be
> applications that rely on the old behavior. Therefore we provide a means
> to switch back to the old behavior using a new multicast socket option
> 
> 	IP_MULTICAST_ALL
> 
> If set then all multicast traffic to the port is forwarded to the socket
> (additional constraints are the SSM inclusion and exclusion lists!).
> If not set (default) then only traffic for multicast groups that were
> joined by thesocket is received.
> 
I think your comment is reveresed here isn't it?  the default you have below is
that mc_all is set, which defaults you to the existing behavior, rather than the
new behavior introduced by this patch.


Ack to the patch though
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Neil


