From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH v2 net-next 0/9] tipc: more updates for the v3.8 content
Date: Fri, 7 Dec 2012 20:19:09 -0500
Message-ID: <1354929558-16948-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63544 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757419Ab2LHBTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 20:19:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes since v1:
	-get rid of essentially unused variable spotted by
	 Neil Horman (patch #2)

	-drop patch #3; defer it for 3.9 content, so Neil,
	 Jon and Ying can discuss its specifics at their
	 leisure while net-next is closed.  (It had no
	 direct dependencies to the rest of the series, and
	 was just an optimization)

	-fix indentation of accept() code directly in place
	 vs. forking it out to a separate function (was patch
	 #10, now patch #9).

Rebuilt and re-ran tests just to ensure nothing odd happened.

Original v1 text follows, updated pull information follows that.

           ---------

Here is another batch of TIPC changes.  The most interesting
thing is probably the non-blocking socket connect - I'm told
there were several users looking forward to seeing this.

Also there were some resource limitation changes that had
the right intent back in 2005, but were now apparently causing
needless limitations to people's real use cases; those have
been relaxed/removed.

There is a lockdep splat fix, but no need for a stable backport,
since it is virtually impossible to trigger in mainline; you
have to essentially modify code to force the probabilities
in your favour to see it.

The rest can largely be categorized as general cleanup of things
seen in the process of getting the above changes done.

Tested between 64 and 32 bit nodes with the test suite.  I've
also compile tested all the individual commits on the chain.

I'd originally figured on this queue not being ready for 3.8, but
the extended stabilization window of 3.7 has changed that.  On
the other hand, this can still be 3.9 material, if that simply
works better for folks - no problem for me to defer it to 2013.
If anyone spots any problems then I'll definitely defer it,
rather than rush a last minute respin.

Thanks,
Paul.
---

The following changes since commit b93196dc5af7729ff7cc50d3d322ab1a364aa14f:

  net: fix some compiler warning in net/core/neighbour.c (2012-12-05 21:50:37 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next_v2

for you to fetch changes up to 0fef8f205f6f4cdff1869e54e44f317a79902785:

  tipc: refactor accept() code for improved readability (2012-12-07 17:23:24 -0500)

----------------------------------------------------------------
Erik Hugne (1):
      tipc: remove obsolete flush of stale reassembly buffer

Jon Maloy (1):
      tipc: change sk_receive_queue upper limit

Paul Gortmaker (2):
      tipc: standardize across connect/disconnect function naming
      tipc: refactor accept() code for improved readability

Ying Xue (5):
      tipc: eliminate aggregate sk_receive_queue limit
      tipc: consolidate connection-oriented message reception in one function
      tipc: introduce non-blocking socket connect
      tipc: eliminate connection setup for implied connect in recv_msg()
      tipc: add lock nesting notation to quiet lockdep warning

 net/tipc/link.c   |  44 -------
 net/tipc/port.c   |  32 +++--
 net/tipc/port.h   |   6 +-
 net/tipc/socket.c | 353 ++++++++++++++++++++++++++++++------------------------
 net/tipc/subscr.c |   2 +-
 5 files changed, 225 insertions(+), 212 deletions(-)
