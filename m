From: "David S. Miller" <davem@redhat.com>
Subject: Re: patricia tries vs. hash for routing?
Date: Thu, 18 Sep 2003 20:17:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918201743.11d88366.davem@redhat.com>
References: <20030918172910.GA22091@sirius.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kristen Carlson <kristenc@cs.pdx.edu>
In-Reply-To: <20030918172910.GA22091@sirius.cs.pdx.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Sep 2003 10:29:10 -0700
Kristen Carlson <kristenc@cs.pdx.edu> wrote:

> I'm wondering if somebody has already written a patch that replaces the
> current routing algorithm (hash) with one that is based on a trie based
> algorithm?  I'm also wondering if anybody has done any performance 
> comparisons with very large route tables to see which one scales better?

Patricia trees aren't going to help, most of the overhead in
the routing lookup is in implementing the various fancy features
our routing code supports.  For example, equal cost multi-pathing
and other such things.

The front end routing cache is a straight hash and is thus the
fastest way to lookup a route.  In the presence of well behaved
traffic and routing tables that do not change too often, it is
optimal.
