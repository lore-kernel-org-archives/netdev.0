From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: v3 [Re-Send] [PATCH 0/5] dccp: Feature negotiation, Part I -
	Underlying data structures
Date: Wed, 5 Nov 2008 07:51:46 +0100
Message-ID: <20081105065146.GB3482@gerrit.erg.abdn.ac.uk>
References: <20081005.091334.208715265.davem@davemloft.net> <20081011073113.GA9205@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:38921 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750807AbYKEGvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2008 01:51:55 -0500
Content-Disposition: inline
In-Reply-To: <20081011073113.GA9205@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

as requested circa two weeks ago, I am now resending the first chunk of the
feature-negotiation patch set.

These patches are identical to the earlier submission.

Can you please let me know when it would be okay to submit the next
instalment of this series.

Gerrit


Changes relative to revision 2
------------------------------
 * reordered patches to eliminate build warnings (reducing patch sizes); 
 * in addition, sparse-build warnings were also eliminated;
 * all patches again verified to compile without build errors.


Changes relative to revision 1
------------------------------
 * [1/5] streamlined field layout reducing the size per each entry;
 * [2/5] migration of function 'dccp_default_value' to a later in the set
         where it is first used.


Commit summary
--------------
This is the first set of the feature negotiation patches. These provide a 
self-contained feature negotiation API for the DCCP protocol (RFC 4340-2).

The whole set is structured into 3 main blocks - (1) basis, (2) core,
(3) integration and cleanup. Within these blocks, this is the first,
self-contained, set and its purpose is to provide
 (a) the underlying datastructures
 (b) initialisation and cleanup routines for the new datastructures.


List of patches in this set:
----------------------------
Patch #1: Provides the basic datastructure for feature negotiation. It gets 
          around the problem that feature-negotiation values have no uniform
	  type - they can be 48-bit numbers, single characters, 2-byte integers
	  or a list of unsigned chars.
Patch #2: Provides a lookup-table for the different negotiable features.
Patch #3: Adds list management for the list keeping the negotiation-options.
Patch #4: Initialisation routines (for request sockets and normal sockets).
Patch #5: Analogous to #4, this provides the cleanup routines.	  

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=228d610abf614d981cceabab3c27c1d3837e43ca

Patch stats:
------------
 include/linux/dccp.h |   13 ++-
 net/dccp/dccp.h      |    5 +
 net/dccp/feat.c      |  167 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/feat.h      |   62 ++++++++++++++++++
 net/dccp/input.c     |    2 
 net/dccp/ipv4.c      |    4 -
 net/dccp/ipv6.c      |    4 -
 net/dccp/minisocks.c |    7 +-
 net/dccp/proto.c     |    3 
 9 files changed, 256 insertions(+), 11 deletions(-)

