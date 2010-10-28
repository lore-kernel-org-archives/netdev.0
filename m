From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/4] dccp: CCID packet dequeueing interface
Date: Thu, 28 Oct 2010 07:16:24 +0200
Message-ID: <1288242988-5333-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_packet_dequeueing_interface_set_of_4>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:39579 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752633Ab0J1FQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 01:16:45 -0400
In-Reply-To: <dccp_packet_dequeueing_interface_set_of_4>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

can you please consider the following set of 4, which solves several problems
of the CCID packet-dequeueing interface. This set has been tested for about
3 years.

 Patch #1: sets up a return code convention to handle both rate-based and
           window-based congestion-control IDs (CCIDs) with one function.
 Patch #2: generalizes the xmit interface: rate-based CCIDs continue to use 
           timers, whereas window-based ones use a tasklet.
 Patch #3: fixes issues in cleaning up CCID state when closing a connection,
           like patch #2 this also divides into rate-based/window-based.
 Patch #4: using the previous patches, takes CCID-2 out of its polling mode
           (that was the problem of the xmit interface - CCID-2 kept on 
	    abusing it by faking a small timeout, constantly polling until
	    its internal congestion state allowed it to send again).

The set has also been placed into a fresh (today's) copy of net-next-2.6, on

    git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']

The set is fully bisectable.    
---
 include/linux/dccp.h   |    4 +-
 net/dccp/ccid.h        |   34 +++++++-
 net/dccp/ccids/ccid2.c |   23 ++++--
 net/dccp/ccids/ccid2.h |    5 +
 net/dccp/ccids/ccid3.c |   12 ++--
 net/dccp/dccp.h        |    5 +-
 net/dccp/output.c      |  209 +++++++++++++++++++++++++++++-------------------
 net/dccp/proto.c       |   21 +++++-
 net/dccp/timer.c       |   27 ++++---
 9 files changed, 223 insertions(+), 117 deletions(-)
