From: David Miller <davem@davemloft.net>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Thu, 26 Aug 2010 17:06:14 -0700 (PDT)
Message-ID: <20100826.170614.02282407.davem@davemloft.net>
References: <1282823827.2476.663.camel@edumazet-laptop>
	<alpine.WNT.2.00.1008260835020.2008@cluij.ucs.ualberta.ca>
	<20100826165359.3b79b27d@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tsi@ualberta.ca, eric.dumazet@gmail.com, bhutchings@solarflare.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53347
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752015Ab0H0AF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 20:05:59 -0400
In-Reply-To: <20100826165359.3b79b27d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 26 Aug 2010 16:53:59 -0700

> On Thu, 26 Aug 2010 08:43:42 -0600 (Mountain Daylight Time)
> Marc Aurele La France <tsi@ualberta.ca> wrote:
> 
>> Right.  And a 65520 MTU allocates sk_buff's with 128K contiguous payloads.
> 
> Infiniband device driver needs to be fixed to do SG and checksum offload.

Agreed, this problem is in the infiniband layer and should be fixed
there.

But I fear there is a real potential blocker for this, if the
infiniband layer can't checksum transmit packets in hardware we cannot
legitimately add SG support.

Paged SKBs can have references to page cache pages and similar.  These
can be updated asynchronously to the transmit, there is no locking at
all to freeze the contents, and therefore full checksum offload is
required to support SG correctly.

So don't get the idea to do the checksum in software in the infiniband
layer, and advertize hw checksumming support, to get around this :-)
