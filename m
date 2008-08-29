From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 08/37] dccp: Query supported CCIDs
Date: Fri, 29 Aug 2008 08:17:04 +0200
Message-ID: <20080829061704.GE3557@gerrit.erg.abdn.ac.uk>
References: <1219945512-7723-1-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-6-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk> <20080828210031.GO9193@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:37294 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752248AbYH2GR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 02:17:26 -0400
Content-Disposition: inline
In-Reply-To: <20080828210031.GO9193@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Arnaldo:
| Em Thu, Aug 28, 2008 at 07:44:43PM +0200, Gerrit Renker escreveu:
| > This provides a data structure to record which CCIDs are locally supported
| > and three accessor functions:
| >  - a test function for internal use which is used to validate CCID requests
| >    made by the user;
| >  - a copy function so that the list can be used for feature-negotiation;
| >  - documented getsockopt() support so that the user can query capabilities.
| > 
| > The data structure is a table which is filled in at compile-time with the
| > list of available CCIDs (which in turn depends on the Kconfig choices).
| > 
| > Using the copy function for cloning the list of supported CCIDs is useful for
| > feature negotiation, since the negotiation is now with the full list of available
| > CCIDs (e.g. {2, 3}) instead of the default value {2}. This means negotiation
| > will not fail if the peer requests to use CCID3 instead of CCID2.
| 
| But this limits us to the CCIDs at kernel build time, what if I want to
| test CCID4? I guess we could have something like a bitmap and check if
| the bit for that CCID is set, and it would be set at ccid_register time.
| 
| Perhaps using include/linux/bitmap.h :-)
| 
Or have a look at how it has been done in the CCID-4 subtree for about a year?
Please take a look at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=d88f6d5505f83f4c19a3417fbf3ee8874c87d227

And also (shows age of the patches):
http://www.mail-archive.com/dccp@vger.kernel.org/msg02613.html	

