From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: BUG: sky2: hw csum failure with dual-port copper NIC on SMP
Date: Tue, 13 Nov 2007 15:27:55 -0800
Message-ID: <20071113152755.4d55c86a@freepuppy.rosehill>
References: <4739E425.20408@cybernetics.com>
	<20071113141414.0959735a@freepuppy.rosehill>
	<473A2BC8.7000909@cybernetics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tony Battersby <tonyb@cybernetics.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34864 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752118AbXKMX3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 18:29:53 -0500
In-Reply-To: <473A2BC8.7000909@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Nov 2007 17:57:12 -0500
Tony Battersby <tonyb@cybernetics.com> wrote:

> Stephen Hemminger wrote:
> > I can reproduce the problem under load with only a single port on 2.6.23.
> > I haven't been able to reproduce it on 2.6.24-rc2 (latest) but that maybe
> > because of either insufficient stress or another bug fix correcting the
> > problem.  There is an issue with Yukon XL updating the receive status index
> > before updating the receive status structure, that is now fixed in 2.6.24.
> > The fix is:
> >
> > commit ab5adecb2d02f3688719dfb5936a82833fcc3955
> > Author: Stephen Hemminger <shemminger@linux-foundation.org>
> > Date:   Mon Nov 5 15:52:09 2007 -0800
> >
> >     sky2: status ring race fix
> >     
> >     The D-Link PCI-X board (and maybe others) can lie about status
> >     ring entries. It seems it will update the register for last status
> >     index before completing the DMA for the ring entry. To avoid reading
> >     stale data, zap the old entry and check.
> >     
> >     Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> >     Signed-off-by: Jeff Garzik <jeff@garzik.org>
> The kernel I tested (2.6.24-rc2-git3) has this patch in it already.
> Perhaps that is why the problem happens less frequently with that
> kernel, but it didn't fix it entirely.
> 
> Do you want the test program I am using? It is a pretty basic
> send()/recv() program, ~650 lines of C.
> 
> Tony
> 

Not really, iperf drives the problem fine.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
