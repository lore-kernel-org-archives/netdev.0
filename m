From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/4] dccp: Completing feature negotiation
Date: Sat, 17 Jan 2009 10:36:29 +0100
Message-ID: <1232184993-9927-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20090104.214605.153723453.davem@davemloft.net>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:57867 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756426AbZAQJgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Jan 2009 04:36:45 -0500
In-Reply-To: <20090104.214605.153723453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following the re-design of the CCID-plugin loading into dccp.ko and further
testing, please find attached the patch set to complete the implementation
of static feature negotiation in DCCP.

Patches have been tested to compile standalone, with sparse enabled.

Gerrit


Commit summary:
---------------
This set completes the self-contained implementation of static feature
negotiation for DCCP endpoints (RFC 4340 - 4342, RFC 5348).

The whole set is structured into 3 main blocks - (1) basis, (2) core, (3)
integration and cleanup.

This set is the final in block (3) and implements the initialization of
feature-negotiation state. 

There is further work going on in the test tree  to also dynamically update
(non-negotiable) feature values such as Ack Ratio. Before this can be done,
however, the CCIDs themselves need some more work.

List of patches in this set:
----------------------------
Patch #1: Initialisation framework for the supported features.
Patch #2: Adds full support for local/remote Sequence Window.
Patch #3: Initialisation and type-checking of involved sysctls.
Patch #4: A set of (useful) debugging/printing helper functions.

The set is also available for viewing online, beginning at
commit bde1e830e87f3a3e51a72fa5b35405c313b64b74 of
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git

Patch stats:
------------
 Documentation/networking/dccp.txt |    3 
 include/linux/dccp.h              |   51 --------
 net/dccp/dccp.h                   |   21 +--
 net/dccp/feat.c                   |  240 ++++++++++++++++++++++++++++----------
 net/dccp/feat.h                   |   23 +--
 net/dccp/minisocks.c              |   11 -
 net/dccp/options.c                |    8 -
 net/dccp/proto.c                  |    2 
 net/dccp/sysctl.c                 |   43 ++++--
 9 files changed, 237 insertions(+), 165 deletions(-)
