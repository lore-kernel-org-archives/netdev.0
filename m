From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 0/5] dccp: Feature negotiation - continuation of Part II (core)
Date: Sat, 22 Nov 2008 11:30:36 +0100
Message-ID: <1227349841-9440-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54502 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753586AbYKVKar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 05:30:47 -0500
In-Reply-To: <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find in this set the continuation. The patches have been tested to
compile standalone, with sparse checking enabled.

Gerrit


Commit summary:
---------------
This is a continuation of an ongoing submission to provide feature/capability
negotiation for DCCP endpoints (RFC 4340).

The whole set is structured into 3 main blocks - (1) basis, (2) core,
(3) integration and cleanup.

This set continues within the second part (core implementation). I have split
it in such a way that up until here the old code and the new API can co-exist.

In the next (and last) patch set within this block, the old code is step-by-step
superseded by the new API.

The full integration of the new API and clean-up of the old code then happens
in the concluding part (3).


List of patches in this set:
----------------------------
Patch #1: Set/getsockopt support to negotiate CCIDs with the peer.
Patch #2: Socket API to query the current CCID from userspace.
Patch #3: Prepares the variable-length htonl/ntohl functions for 48 bits.
          Such a length is needed by e.g. the Sequence Window feature.
Patch #4: Support for DCCP `Mandatory' type options (RFC 4340, 5.8.2).
Patch #5: Routine to insert feature-negotiation header options.

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=76ae436e9949fd75a4faaa81f5ce915309b83a1f


Patch stats:
------------
 Documentation/networking/dccp.txt |   14 ++++
 include/linux/dccp.h              |    5 +
 net/dccp/ackvec.c                 |    9 +-
 net/dccp/ackvec.h                 |    5 -
 net/dccp/ccid.h                   |   18 +++++
 net/dccp/feat.h                   |   20 +++++
 net/dccp/options.c                |  127 +++++++++++++++++---------------------
 net/dccp/probe.c                  |    7 --
 net/dccp/proto.c                  |   44 +++++++++++++
 9 files changed, 169 insertions(+), 80 deletions(-)
