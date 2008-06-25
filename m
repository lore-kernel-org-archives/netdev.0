From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
	available to userspace
Date: Wed, 25 Jun 2008 19:05:45 +0100
Message-ID: <20080625180545.GB8260@gerrit.erg.abdn.ac.uk>
References: <20080517155916.34622BD22@poczta.oswiecenia.net> <200806202303.37924.tomasz@grobelny.oswiecenia.net> <20080623165826.GB8692@gerrit.erg.abdn.ac.uk> <200806241002.42482.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63315 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751778AbYFYSGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 14:06:13 -0400
Content-Disposition: inline
In-Reply-To: <200806241002.42482.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > Yes having them separate gives a clearer semantics. But it comes at a price
| > - to retrieve the parameters, we need an extra function or lookup table.
| >
| An additional bitfield in dccp_qpolicy_operations should do it when it comes 
| to storing that information. When it comes to retrieving see next point...
| 
| > Maybe there is an elegant solution which allows to encode the required
| > parameters while keeping the semantics clear?
| >
| What about something like:
| 	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_ID, DCCPQ_POLICY_PRIO);
| to choose policy (exactly as it is now) and a new function to ensure that the 
| kernel understands parameters:
| 	setsockopt(sockfd, DCCP_SOCKOPT_QPOLICY_PARAMS, DCCP_SCM_PRIORITY | DCCP_SCM_TIMEOUT);
| 
| The second call would return an error if the kernel does not know anything 
| about DCCP_SCM_TIMEOUT (or a choosen policy does not support it). This would 
| have the additional benefit (over similar getsockopt) that the kernel will be 
| able to optimize its behaviour knowning the set of parameters that will be 
| used.
| 
| What do you think about such an interface?
| -- 
In both solutions there is a need to maintain an integrity constraint
between the qpolicy ID and the set of parameters that the qpolicy uses.

With the bitmask approach this constraint is expressed only once, when
the policy is defined in the source file.

With the socket approach, the constraint needs to be expressed each time
the policy is used.

I don't know your reservations against the bitmask approach (other than the
semantics), but I find having to define the parameters each time the qpolicy
is used cumbersome, and it can also be a source of errors.

Gerrit
