From: Jeff Moyer <jmoyer@redhat.com>
Subject: napi poll and dev->weight
Date: Fri, 22 Apr 2005 13:16:21 -0400
Message-ID: <17001.12645.981316.510106@segfault.boston.redhat.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mpm@selenic.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, Matt,

I recently debugged an issue we had with netdump, where a NAPI poll would
exhaust the network card's budget.  In this case, the budget was never
reset (since we are in a panicked state), and so the card's poll routine
would always return immediately without doing any work.

While other netpoll users may not have exactly the same problems, this
could become an issue in the places where you call netpoll_poll in a loop
(such as in find_skb and netpoll_send_skb).  You might consider a check
like the following in such cases:

  if (dev->quota <= 0)
  	dev->quota += dev->weight;

This will at least make it possible for the poll routine to make progress.

If any of this is unclear, feel free to tell me so.  I'll gladly elaborate.

-Jeff
