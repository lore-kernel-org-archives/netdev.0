From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in filter add
Date: Tue, 20 Mar 2007 15:48:53 +0100
Message-ID: <45FFF455.80003@trash.net>
References: <45FEEE35.6090606@reflexsecurity.com>	 <20070319.192206.21926062.davem@davemloft.net> <1174373645.4895.15.camel@localhost> <45FFEC78.2090708@reflexsecurity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Chris Madden <chris@reflexsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51548 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933506AbXCTOtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 10:49:01 -0400
In-Reply-To: <45FFEC78.2090708@reflexsecurity.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Madden wrote:
> Ok, I replaced ingress_lock with queue_lock in ing_filter and it died in
> the same place.  Trace below (looks to be substantively the same)...
> 
> If I am reading tc_ctl_tfilter correctly, we are adding our new
> tcf_proto to the end of the list, and it is getting used before the
> change function is getting executed on it.   Locking the ingress_lock in
> qdisc_lock_tree ( in addition to the extant queue_lock )seems to have
> the same effect; I can get  a traceback from that if its useful.


The problem is that some classifiers (like basic, fw and route)
implement empty ->init functions, although fw and route properly
deal with it in their classification functions. The ->init function
should allocate and initalize tp->root, which basic fails to do.
If you give me a few hours I'll cook up a patch for this.

