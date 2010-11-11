From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/3] dccp: Ack Vectors in circular buffer instead of array
Date: Thu, 11 Nov 2010 07:07:30 +0100
Message-ID: <1289455653-5463-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <ack_vector_circular_buffer_dccp>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:50877 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753636Ab0KKGHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Nov 2010 01:07:44 -0500
In-Reply-To: <ack_vector_circular_buffer_dccp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

please can you consider this set, which is part I of a two-part patch set
to fix issues in the DCCP Ack Vector implementation.

It is a self-contained set to move away from a linear array to a circular
buffer with overflow handling. Part II would then follow next week.


 Patch #1: cleans up the old interface to prepare for the improved one.
 Patch #2: also tidies up the old interface, by separating the internals
           of Ack Vectors from the option-parsing code.
 Patch #3: Completes the implementation of a circular Ack Vector buffer.


I have also placed this in into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

The set has been tested for 3 years, and is fully bisectable.
---
 net/dccp/ackvec.c      |  251 ++++++++++++++++--------------------------------
 net/dccp/ackvec.h      |  115 +++++++++++++----------
 net/dccp/ccids/ccid2.c |   13 +--
 net/dccp/dccp.h        |   11 ++-
 net/dccp/input.c       |    6 +-
 net/dccp/options.c     |   65 ++++++++++++-
 6 files changed, 225 insertions(+), 236 deletions(-)
