From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/5] net: Make rtnetlink infrastructure network namespace aware
Date: Sat, 29 Sep 2007 10:51:14 -0600
Message-ID: <m1tzpd8lfh.fsf@ebiederm.dsl.xmission.com>
References: <m1myv69tfu.fsf@ebiederm.dsl.xmission.com>
	<m1hcle9td8.fsf@ebiederm.dsl.xmission.com>
	<46FE72E3.3000402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36024 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756394AbXI2Qvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 12:51:47 -0400
In-Reply-To: <46FE72E3.3000402@trash.net> (Patrick McHardy's message of "Sat,
	29 Sep 2007 17:44:35 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> I'm wondering why this receive queue processing on unlock is still
> necessary today, we don't do trylock in rtnetlink_rcv anymore, so
> all senders will simply wait until the lock is released and then
> process the queue.

Good question, I should probably look.  I was lazy and didn't go back
and audit why we were doing this.  I just coded a routine that I was
certain would work.  It does appear that we are processing the queue
with sk_data_read when we add a message, so this may be completely
unnecessary.  I will go back and look.  If we can remove this bit
things should be simpler.

Eric

