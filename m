From: Olof Johansson <olof@lixom.net>
Subject: Dealing with limited resources and DMA Engine copies
Date: Wed, 13 Feb 2008 20:38:15 -0600
Message-ID: <20080214023815.GA5414@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shannon.nelson@intel.com, dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:39092 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752210AbYBNCf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Feb 2008 21:35:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

My DMA Engine has a limited resource: It's got a descriptor ring, so
it's not always possible to add a new descriptor to it (i.e. it might be
full). While allocating a huge ring will help, eventually I'm sure I
will hit a case where it'll overflow.

I thought this was going to be taken care of automatically by the fact
that you return your max(?) number of descriptors in the channel
allocation function, but it looks like that value is discarded in
dma_client_chan_alloc().

So, I just got a couple of spurious:
dma_cookie < 0
dma_cookie < 0

...on the console and the connection terminated. Looks like that came
from tcp_recvmsg(). Ouch.

How about falling back to the cpu-based copy in case of failure? Or would
you prefer that I sleep locally in my driver and wait on a descriptor
slot to open up?


-Olof
