From: Roland Dreier <rdreier@cisco.com>
Subject: Re: RDMA/nes: Fix mis-merge
Date: Thu, 26 Mar 2009 16:53:25 -0700
Message-ID: <ada8wmru9hm.fsf@cisco.com>
References: <20090326.152515.43533230.davem@davemloft.net>
	<alpine.LFD.2.00.0903261555290.3032@localhost.localdomain>
	<adahc1fuarm.fsf_-_@cisco.com>
	<20090326.163114.131582923.davem@davemloft.net>
	<alpine.LFD.2.00.0903261638360.3994@localhost.localdomain>
	<alpine.LFD.2.00.0903261639150.3994@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:18116 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762315AbZCZXx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 19:53:27 -0400
In-Reply-To: <alpine.LFD.2.00.0903261639150.3994@localhost.localdomain> (Linus
	Torvalds's message of "Thu, 26 Mar 2009 16:41:15 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > Btw, as far as I can tell, that function had never been tested with any 
 > polling. It had a line like
 > 
 > 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 > 
 > but that line was _before_ 'nesvnic' was actually initialized (well, it 
 > had been initialized to NULL, so it passed in some NULL-pointer-offset to 
 > that function).

Yes, looks like the bug was introduced by d0929553 ("infiniband: convert
nes driver to net_device_ops").  And unfortunately the nesvnic=NULL
initialization stopped gcc from warning about used-uninitialized I
guess.  I'll test the final merge out...

 - R.
