From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reference the ipv4 sysctl table header
Date: Wed, 28 Mar 2012 16:51:32 -0400 (EDT)
Message-ID: <20120328.165132.1309449708287640005.davem@davemloft.net>
References: <20120326222359.GB28123@dztty>
	<20120326.182411.41401140080225401.davem@davemloft.net>
	<20120328163219.GA19778@home.goodmis.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tixxdz@opendz.org, ebiederm@xmission.com, viro@zeniv.linux.org.uk,
	netdev@vger.kernel.org
To: rostedt@goodmis.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758036Ab2C1Uvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 16:51:38 -0400
In-Reply-To: <20120328163219.GA19778@home.goodmis.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 28 Mar 2012 12:32:20 -0400

> I just started using kmemleak and notice that it reports false positives
> for several __init functions that call register_sysctl_paths(). The fix
> you want is:
> 
> {
> 	sturct ctl_table_header *head;
> 
> 	head = register_sysctl_paths(ipv4_path, ipv4_skeleton);
> 	BUG_ON(!head);
> 	kmemleak_ignore(head);
> 
> 
> No need to waste a pointer just to keep the reference around for
> kmemleak.

That looks a lot saner than the other suggestions, indeed.
