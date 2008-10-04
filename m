From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: v2 [PATCH 0/5] dccp: Feature negotiation, Part I - Underlying data structures
Date: Sat,  4 Oct 2008 11:13:21 +0200
Message-ID: <1223111606-5308-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20081002.125252.202124982.davem@davemloft.net>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52934 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752140AbYJDJNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Oct 2008 05:13:34 -0400
In-Reply-To: <20081002.125252.202124982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please find below the revised patch set, addressing earlier review.


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


Patch stats:
------------
 include/linux/dccp.h |   13 +-
 net/dccp/dccp.h      |    5 
 net/dccp/feat.c      |  270 +++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/feat.h      |   62 +++++++++++
 net/dccp/input.c     |    2 
 net/dccp/ipv4.c      |    4 
 net/dccp/ipv6.c      |    4 
 net/dccp/minisocks.c |    7 +
 net/dccp/proto.c     |    3 
 9 files changed, 359 insertions(+), 11 deletions(-)

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=3136a0e06ba53fa4be7114c3e8148c96cc8cf6b1

