From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather
 than individually
Date: Sat, 07 Jan 2012 10:18:20 -0800 (PST)
Message-ID: <20120107.101820.1395301647780373402.davem@davemloft.net>
References: <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120105.141331.83457091828476806.davem@davemloft.net>
	<1325793658.29084.21.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab2AGSSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 13:18:24 -0500
In-Reply-To: <1325793658.29084.21.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Thu, 5 Jan 2012 20:00:58 +0000

> Although this scheme works fine for Xen's netback I don't think it works
> for other use cases like the NFS one (or basically any kernel_sendpage
> usage). In those cases you don't want to wait for the last core mm ref
> on the page to get dropped, you just want to wait for the last ref due
> to the particular sendpage. If you use the core page_count() reference
> count then you end up waiting for the process to exit (and drop the core
> reference count) before the destructor fires and you can complete the
> write, which is obviously not what is desired!
> 
> There's also issues with things like two threads simultaneously doing
> I/O from the same page. If one lot of I/O is to NFS and the other to
> iSCSI (assuming they both use this facility in the future) then they
> will clash over the use of the struct page field. In fact even if they
> were both to NFS I bet nothing good would happen...

Ok, struct page doesn't seem the best place for this stuff then.

Thanks.
