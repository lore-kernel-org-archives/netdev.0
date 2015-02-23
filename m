From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Ottawa and slow hash-table resize
Date: Mon, 23 Feb 2015 10:49:04 -0800
Message-ID: <20150223184904.GA24955@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	josh@joshtriplett.org
To: alexei.starovoitov@gmail.com, herbert@gondor.apana.org.au,
	tgraf@suug.ch, kaber@trash.net, davem@davemloft.net,
	ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60881 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbBWStM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 13:49:12 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 23 Feb 2015 11:49:11 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Alexei mentioned that there was some excitement a couple of weeks ago in
Ottawa, something about the resizing taking forever when there were large
numbers of concurrent additions.  One approach comes to mind:

o	Currently, the hash table does not allow additions concurrently
	with resize operations.  One way to allow this would be to
	have the addition operations add to the new hash table at the
	head of the lists.  This would clearly require also updating the
	pointers used to control the unzip operation.

o	Count the number of entries added during the resize operation.
	Then, at the end of the resize operation, if enough entries have
	been added, do a resize, but by multiple factors of two if
	need be.

This should allow the table to take arbitrarily large numbers of updates
during a resize operation.  There are some other possibilities if this
approach does not work out.

Thoughts?

							Thanx, Paul
