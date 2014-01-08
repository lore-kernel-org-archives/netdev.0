From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2] xen-netback: stop vif thread spinning if
 frontend is unresponsive
Date: Wed, 8 Jan 2014 19:37:16 +0000
Message-ID: <20140108193716.GA16009@zion.uk.xensource.com>
References: <1389184918-42790-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27844 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbaAHThS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 14:37:18 -0500
Content-Disposition: inline
In-Reply-To: <1389184918-42790-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 12:41:58PM +0000, Paul Durrant wrote:
> The recent patch to improve guest receive side flow control (ca2f09f2) had a
> slight flaw in the wait condition for the vif thread in that any remaining
> skbs in the guest receive side netback internal queue would prevent the
> thread from sleeping. An unresponsive frontend can lead to a permanently
> non-empty internal queue and thus the thread will spin. In this case the
> thread should really sleep until the frontend becomes responsive again.
> 
> This patch adds an extra flag to the vif which is set if the shared ring
> is full and cleared when skbs are drained into the shared ring. Thus,
> if the thread runs, finds the shared ring full and can make no progress the
> flag remains set. If the flag remains set then the thread will sleep,
> regardless of a non-empty queue, until the next event from the frontend.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

Thanks
Wei.
