From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 10:37:18 +0100
Message-ID: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk> <20080513.003924.170616140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org, acme@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:38149 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750899AbYEMJhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 05:37:52 -0400
Content-Disposition: inline
In-Reply-To: <20080513.003924.170616140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| 
| > Is there support for this change or are there reasons to keep SOCK_DCCP?
| 
| You'll have to accept it forever since there have been several
| kernel releases already with DCCP support added and there are
| applications out there.
| 
And maybe it is not necessary or worth to change it. 

But there is a problem, the cause is not necessarily the above:

 * using an ai_socktype=0 used to work for DCCP; on dual-stack hosts,
   IPv6 addresses were returned first, so that both IPv6 and IPv4
   clients (v6-mapped-v4) could connect to the server,

 * within the last three months there was a change in the lookup
   behaviour so that now IPv4 addresses are returned first on dual
   stack hosts when AF_UNSPEC is specified with ai_socktype=0,

 * changing preference values in /etc/gai.conf did not help,

 * the only fix was the following (pretend to be UDP):

	if (inSettings->mProtocol == IPPROTO_DCCP)
		hints.ai_socktype = SOCK_DGRAM;

Maybe there is a better fix for this.
