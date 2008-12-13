From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
	negotiation
Date: Sat, 13 Dec 2008 15:56:55 +0100
Message-ID: <20081213145655.GA14240@gerrit.erg.abdn.ac.uk>
References: <20081208.011917.176472177.davem@davemloft.net> <1229175685-18716-1-git-send-email-gerrit@erg.abdn.ac.uk> <1229175685-18716-2-git-send-email-gerrit@erg.abdn.ac.uk> <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk> <e2d7436a0812130555r52422bel1dd9b66ba8479e2a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Micha? Miros?aw <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52445 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758013AbYLMO5E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Dec 2008 09:57:04 -0500
Content-Disposition: inline
In-Reply-To: <e2d7436a0812130555r52422bel1dd9b66ba8479e2a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > +static int ccid_request_module(u8 id)
| > +{
| > +       if (!in_atomic()) {
| > +               ccids_read_lock();
| > +               if (ccids[id] == NULL) {
| > +                       ccids_read_unlock();
| > +                       return request_module("net-dccp-ccid-%d", id);
| > +               }
| > +               ccids_read_unlock();
| > +       }
| > +       return 0;
| > +}
| 
| Just a random thought: does this lock really do anything useful here?
| 
Reading the (shared) 'ccids' array is the solution chosen to check whether
the module for CCID with number 'id' is already loaded.

It would be bad to call request_module() each time a new DCCP socket is
opened. Using the 'ccids' array may not be the only way to check whether
a given module (whose name depends on the value of 'id') is loaded. 

But if this solution is chosen, then it requires to protect the read
access to 'ccids', which is shared among all DCCP sockets.
