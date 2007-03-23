From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Fri, 23 Mar 2007 12:59:15 -0400
Message-ID: <1174669155.10788.60.camel@localhost.localdomain>
References: <200703221835.l2MIZdDw007850@faith.austin.ibm.com>
	 <20070322.120139.74735307.davem@davemloft.net>
	 <1174598630.3085.285.camel@faith.austin.ibm.com>
	 <Line.LNX.4.64.0703221943110.24461@d.namei>
	 <1174628387.10788.53.camel@localhost.localdomain>
	 <1174667591.3085.308.camel@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@namei.org>,
	David Miller <davem@davemloft.net>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, vyekkirala@TrustedCS.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:35401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992527AbXCWRDm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 13:03:42 -0400
In-Reply-To: <1174667591.3085.308.camel@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-03-23 at 10:33 -0600, Joy Latten wrote:
> On Fri, 2007-03-23 at 01:39 -0400, Eric Paris wrote:
> 
> > 
> > In either case though proper auditing needs to be addressed.  I see that
> > the first patch from Joy wouldn't audit deletion failures.  It appears
> > to me if the check is done per policy then the security hook return code
> > needs to be recorded and passed to xfrm_audit_log instead of the hard
> > coded 1 result used now.
> > 
> > Assuming we go with James's double loop what should we be auditing for a
> > security hook denial?  Just audit the first policy entry which we tried
> > to remove but couldn't and then leave the rest of the auditing in those
> > functions the way it is now in case there was no denial, calling
> > xfrm_audit_log with a hard coded 1 for the result?
> > 
> Actually, I thought the original intent of the ipsec auditing was to
> just audit changes made to the SAD/SPD databases, not securiy hook
> denials, right? 

Then what is the point of the 'result' field that we capture and log in
xfrm_audit_log if the only things you care to audit are successful
changes to the databases?

-Eric

