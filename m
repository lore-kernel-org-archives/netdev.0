From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom the host TCP port space.
Date: 20 Aug 2007 13:07:06 +0200
Message-ID: <p733aye1n39.fsf@bingen.suse.de>
References: <8A71B368A89016469F72CD08050AD334018E20BC@maui.asicdesigners.com>
	<20070819.174017.77241227.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com>
	<20070819.180540.74750322.davem@davemloft.net>
	<8A71B368A89016469F72CD08050AD334018E20C1@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David Miller" <davem@davemloft.net>, <sean.hefty@intel.com>,
	<netdev@vger.kernel.org>, <rdreier@cisco.com>,
	<general@lists.openfabrics.org>, <linux-kernel@vger.kernel.org>,
	<jeff@garzik.org>
To: "Felix Marti" <felix@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33576 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbXHTKNM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 06:13:12 -0400
In-Reply-To: <8A71B368A89016469F72CD08050AD334018E20C1@maui.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Felix Marti" <felix@chelsio.com> writes:
> > avoidance gains of TSO and LRO are still a very worthwhile savings.
> So, i.e. with TSO, your saving about 16 headers (let us say 14 + 20 +
> 20), 864B, when moving ~64KB of payload - looks like very much in the
> noise to me.

TSO is beneficial for the software again. The linux code currently
takes several locks and does quite a few function calls for each 
packet and using larger packets lowers this overhead. At least with
10GbE saving CPU cycles is still quite important.

> an option to get 'high performance' 

Shouldn't you qualify that?

It is unlikely you really duplicated all the tuning for corner cases
that went over many years into good software TCP stacks in your
hardware.  So e.g. for wide area networks with occasional packet loss
the software might well perform better.

-Andi
