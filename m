From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
	negotiation
Date: Tue, 16 Dec 2008 06:29:54 +0100
Message-ID: <20081216052954.GA6199@gerrit.erg.abdn.ac.uk>
References: <20081208.011917.176472177.davem@davemloft.net> <1229175685-18716-1-git-send-email-gerrit@erg.abdn.ac.uk> <1229175685-18716-2-git-send-email-gerrit@erg.abdn.ac.uk> <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk> <e2d7436a0812130555r52422bel1dd9b66ba8479e2a@mail.gmail.com> <20081213145655.GA14240@gerrit.erg.abdn.ac.uk> <e2d7436a0812140650r41b601dfgc3bbf41f01c2bb5d@mail.gmail.com> <36660.148.187.160.35.1229358346.squirrel@148.187.160.35>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Micha? Miros?aw <mirqus@gmail.com>, acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:50193 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750787AbYLPFaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 00:30:24 -0500
Content-Disposition: inline
In-Reply-To: <36660.148.187.160.35.1229358346.squirrel@148.187.160.35>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| Hence I think we have a chance by going completely lockless here, by
| loading all configured CCIDs at runtime. In this manner the per-connection
| check "are all advertised CCIDs are loaded?" falls under the table, we
| do not need to worry about concurrent access, and loading DCCP implies that
| all needed CCIDs are there.
Unfortunately this won't work since the CCIDs depend on dccp.ko being
fully loaded, so requiring that CCID module are loaded during the
loading process of dccp.ko creates a cyclic dependency.
