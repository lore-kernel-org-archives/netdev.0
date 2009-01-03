From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [Patch 0/3] dccp: Lockless use of CCID blocks
Date: Sat,  3 Jan 2009 08:30:46 +0100
Message-ID: <1230967849-9456-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20090101104923.GA4269@gerrit.erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:57722 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750767AbZACHbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jan 2009 02:31:05 -0500
In-Reply-To: <20090101104923.GA4269@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please find attached an updated and tested revision of the earlier 
patch set to enable lockless use of CCID plugins within DCCP.

It combines the initial patch by Arnaldo with further work, following
discussions on this mailing list.

All patches have been compile individually (sparse enabled) and have
been verified to work.

Wishing a good new year
Gerrit


Changes relative to earlier revision:
-------------------------------------
 * incorporated Arnaldo's feedback regarding the deletion of jump labels
 * and the renaming of the register/unregister functions (for want of a
   better word, 'activate' has been used here);
 * added un-registration function to allow module unloading;
 * removed now obsolute module references from the CCIDs (ccid_owner);
 * updated Kconfig menu to reflect all the new changes.


List of patches:
----------------
Patch #1: Integrates CCID plugins with dccp.ko main module.
Patch #2: Cleans up the old interface.
Patch #3: Integrates the TFRC library, a dependency of CCID-3.


The set is also available for online viewing, at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=07b69e62ebcb01c4ec9e372e70aabbdd21d9c4fc

CCID-4 has also been updated and likewise been tested - negotiation,
as well as a longer test involving audio streaming.
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=shortlog;h=ccid4


Patch stats:
------------
 net/dccp/Kconfig                    |    4 
 net/dccp/Makefile                   |   15 +
 net/dccp/ackvec.h                   |   53 ------
 net/dccp/ccid.c                     |  300 ++++++++++++++----------------------
 net/dccp/ccid.h                     |   14 -
 net/dccp/ccids/Kconfig              |   73 ++------
 net/dccp/ccids/Makefile             |    9 -
 net/dccp/ccids/ccid2.c              |   22 --
 net/dccp/ccids/ccid3.c              |   23 --
 net/dccp/ccids/lib/Makefile         |    3 
 net/dccp/ccids/lib/loss_interval.c  |    3 
 net/dccp/ccids/lib/packet_history.c |    9 -
 net/dccp/ccids/lib/tfrc.c           |   19 --
 net/dccp/ccids/lib/tfrc.h           |   11 +
 net/dccp/ccids/lib/tfrc_equation.c  |    4 
 net/dccp/dccp.h                     |    2 
 net/dccp/feat.c                     |    6 
 net/dccp/input.c                    |    2 
 net/dccp/proto.c                    |    7 
 19 files changed, 186 insertions(+), 393 deletions(-)
