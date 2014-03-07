From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/12][pull request] Intel Wired LAN Driver
 Updates
Date: Fri, 07 Mar 2014 16:19:33 -0500 (EST)
Message-ID: <20140307.161933.284876266168174096.davem@davemloft.net>
References: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43518 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaCGVTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 16:19:36 -0500
In-Reply-To: <1394161164-26645-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  6 Mar 2014 18:59:12 -0800

> This series contains updates to i40e and i40evf.
> 
> Most notable are:
> Joseph completes the implementation of the ethtool ntuple rule
> management interface by adding the get, update and delete interface
> reset.
> 
> Akeem provides a fix to prevent a possible overflow due to multiplication
> of number and size by using kzalloc, so use kcalloc.
> 
> Jesse provides an implementation for skb_set_hash() and adds the L4 type
> return when we know it is an L4 hash.  He also adds a counter to
> statistics for Tx timeouts to help users.  Lastly he provides a change
> to stay away from the cache line where the done bit may be getting
> written back for the transmit ring since the hardware may be writing the
> whole cache line for a partial update.
> 
> Shannon cleans up code comments.
> 
> Anjali removes a firmware workaround for newer firmware since the number
> of MSIx vectors are being reported correctly.
> 
> v2:
>  -  dropped patch 01 of the series based on feedback from the author
>     Joe Perches and Shannon Nelson.

Pulled, thanks Jeff.

And I'd like to make a broad long-term comment, actually about vf
drivers in general....

There is so much common code between pf and vf drivers, as a quick
example even in this patch set the skb_set_hash() stuff is pretty
much the same for i40e and i40evf.

I realize there are subtle differences between vf and pf, however
you can't say that there isn't a metric ton of common code.

Please consider seriously making a common layer for these kinds of
driver pairs.  I absolutely do not care, as an initial step, if the
common code just gets linked directly into the final module object
for the two drivers.  Although eventually it would be nice if the
common layer driver was a shared module object on it's own that is
simply depended upon by the pf and vf drivers.

Thanks.
