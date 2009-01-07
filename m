From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed, 7 Jan 2009 22:02:30 +0300
Message-ID: <20090107190230.GB11037@ioremap.net>
References: <1231307334-9542-1-git-send-email-michael@laptop.org> <1231307334-9542-2-git-send-email-michael@laptop.org> <20090107114703.GB28161@ioremap.net> <c6d9bea0901071035p1b8b4fc1u49bc7bb7c89782a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:44568 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754611AbZAGTCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 14:02:32 -0500
Content-Disposition: inline
In-Reply-To: <c6d9bea0901071035p1b8b4fc1u49bc7bb7c89782a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2009 at 01:35:13PM -0500, C. Scott Ananian (cscott@laptop.org) wrote:
> I haven't reviewed the patch to confirm this, but this is how I would
> expect RLIMIT_NETWORK functions.  A trusted process like inetd (say)
> would accept a network connection and create a file handle.  It would
> then fork, drop the hard and soft RLIMIT_NETWORK to 0, and then exec
> the untrusted client program.  This would allow the untrusted program
> to use the 'trusted' network resource via the open file handle, but
> prevent it from (say) leaking sensitive transaction data by making
> further connections to some other network resource.  (There are better
> use cases than inetd, of course.)

So effectively it requires higher-prio process to set the limit and then
drop own priviledges. And by default network rlimit is turned off, so
this does not work for usual processes?

The same inetd may setup iptables rule btw. I do not say this is the way
to go, just that it already exists.

> According to man 2 setrlimit, "A child process created via fork(2)
> inherits its parent's resource limits.  Resource limits are preserved
> across execve(2).".

Yes, rlimits are copied in copy_signal(), but when parent sets the
rlimit it is not updated in the childs, so was my question, sorry for
confusion.

-- 
	Evgeniy Polyakov
