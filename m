From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 14:11:29 -0700
Message-ID: <adaps0ml18e.fsf@cisco.com>
References: <adahclymos8.fsf@cisco.com>
	<46E97BB0.9030106@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46E97BB0.9030106@opengridcomputing.com> (Steve Wise's message of
	"Thu, 13 Sep 2007 13:04:32 -0500")
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

 > I was about to post v2 of my patch to avoid port space collisions with
 > the native stack.  Can we get that 2.6.24?  It is high priority
 > IMO. I've tried to solicit review on it, but I think folks are
 > reluctant... ;-)

I would like to get this in, but I'm still at least a little
reluctant, since we would be committing to a user interface that seems
a little awkward at best, so I'd like to try and find something
better.  Just to summarize my understanding:

 - your patch requires the administration to configure an ethX:iwY
   alias address to use iwarp.  (By the way is there anything other
   than "don't do that" that avoids assigning the same address to the
   iwarp alias and a non-iwarp interface?)

 - it would be nicer to create the alias automatically, but an alias
   without an address doesn't make sense.  Creating a whole separate
   net device causes problems because the iwarp stuff still needs to
   use the main net device to do ARP etc.

 - so I'm out of better ideas but I still want to push back a little
   before we commit to something ugly.

I've been meaning to track down the bnx2 iscsi offload patch to look
and see if this issue is addressed, since the same problem seems to
exist: it seems an iscsi connection and a main stack tcp connection
might share the same 4-tuple unless something is done to avoid that
happening.

Also, I think it behooves us to get some agreement on this approach
with NetEffect and Kanoj (NetXen?) at least, since their iwarp drivers
seem to be imminent.

 - R.
