From: David Miller <davem@davemloft.net>
Subject: Re: RDMA/nes: Fix mis-merge
Date: Fri, 27 Mar 2009 00:29:40 -0700 (PDT)
Message-ID: <20090327.002940.55045245.davem@davemloft.net>
References: <alpine.LFD.2.00.0903261638360.3994@localhost.localdomain>
	<alpine.LFD.2.00.0903261639150.3994@localhost.localdomain>
	<ada8wmru9hm.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44806
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753158AbZC0H3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:29:53 -0400
In-Reply-To: <ada8wmru9hm.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Thu, 26 Mar 2009 16:53:25 -0700

>  > Btw, as far as I can tell, that function had never been tested with any 
>  > polling. It had a line like
>  > 
>  > 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
>  > 
>  > but that line was _before_ 'nesvnic' was actually initialized (well, it 
>  > had been initialized to NULL, so it passed in some NULL-pointer-offset to 
>  > that function).
> 
> Yes, looks like the bug was introduced by d0929553 ("infiniband: convert
> nes driver to net_device_ops").  And unfortunately the nesvnic=NULL
> initialization stopped gcc from warning about used-uninitialized I
> guess.  I'll test the final merge out...

Sorry about that, thanks for working this out Roland.
