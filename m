From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: netdev-2.6 [PATCH 0/5] dccp: ccid-2/3 code clean up; TCP RTT estimator
Date: Mon, 23 Aug 2010 07:41:35 +0200
Message-ID: <1282542100-5799-1-git-send-email-gerrit@erg.abdn.ac.uk>
References: <20100820.004005.58446090.davem@davemloft.net>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53587 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753062Ab0HWFlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Aug 2010 01:41:49 -0400
In-Reply-To: <20100820.004005.58446090.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Dave,

please would you consider consider the following DCCP CCID-2/3 set (applies to
netdev-2.6): it does code clean-up and adds a better RTO estimation to CCID-2.


Patch #1: aggregates the cosmetic changes (whitespace, documentation etc.).

Patch #2: removes redundant test for CCID block in LISTEN state. As a byproduct
          of integrating the feature-negotiation changeset last year, that test
	  is now redundant, simplifying the code.

Patch #3: removes a sanity-check function from CCID-2 and provides a (lengthy)
	  explanation why this test is indeed redundant.
	  
Patch #4: simplifies and consolidates the code to rearm the CCID-2 RTO timer.

Patch #5: replaces the broken CCID-2 RTT estimator algorithm with a better one
          ('better' means "stolen from the TCP code", this was not done blindly
	   but as a result of testing, it may even be possible to later share
	   the RTT estimation code between TCP and CCID-2).


All patches have been in the test tree at git://eden-feed.erg.abdn.ac.uk 
for more than 2 years and compile independently.
