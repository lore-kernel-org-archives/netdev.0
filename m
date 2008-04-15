From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Tue, 15 Apr 2008 16:21:13 +0100
Message-ID: <20080415152113.GB20735@gerrit.erg.abdn.ac.uk>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <20080414065041.GA4431@gerrit.erg.abdn.ac.uk> <20080414073915.GA9655@gerrit.erg.abdn.ac.uk> <200804150145.05571.tomasz@grobelny.oswiecenia.net> <20080415151403.GA20735@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:42887 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750711AbYDOPVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 11:21:39 -0400
Content-Disposition: inline
In-Reply-To: <20080415151403.GA20735@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| | What happens if application is compiled with dccp_packet_info containing only 
| | one field (priority) and kernel containing two fields (for example priority 
| | and later added expiry time)? Wouldn't that implementation make extensions to 
| | dccp_packet_info impossible?
| Had not looked at it from this point of view. So you are suggesting
| 
| 	if (msg->msg_control != NULL && msg->msg_controllen >= sizeof(*dcp))
| 		dcp = (struct dccp_packet_info *)msg->msg_control;
| 
| instead? Agreed, point #1 to change in the patch.
| 
No, the above is nonsense. If the application uses an earlier version of the API, then
it needs to be recompiled, there is no way it could pretend to have an adequate size.

So my take is that still the '==' is correct. But maybe this is a known problem?


The University of Aberdeen is a charity registered in Scotland, No SC013683.

