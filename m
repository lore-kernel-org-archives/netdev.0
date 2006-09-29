From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 14:50:03 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF32C@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:29622 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161401AbWI2Su3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 14:50:29 -0400
To: Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >>While I don't see any explicit mention of it in the documentation or
> >>your comments, I assume we would want a flow_out check for 
> >>NetLabel here
> >>as well?
> >  
> > I don't believe we do. By this time, the packet is or 
> should already be
> > carrying the CIPSO/NetLabel option which should already be 
> the right one
> > (derived from the socket or flow as appropriate), but you 
> would want to
> > audit the code to make sure. IOW, the label option in the 
> IP header should
> > already be reflecting the secmark on the skb. But again, 
> you may want to
> > audit the code to make sure.
> 
> In the case above I am concerned about the situation where the
> skb->secmark == 0 and there is a IPv4 option (i.e. it is NetLabel
> labeled) on the packet.

Where we initialize the secmark should be immaterial from the NetLabel
point of view. The kernel mechanisms should assure that the IP option
reflects the MLS portion (or a label in the SA range) elsewhere. In any
case, a flow_out check doesn't make sense since the IP option and the
secmark are (should be) mirroring each other and there's in actuality
no "flow out" happening; they are just 2 representation of the SAME label.

Your suggestion as to adjusting the secmark per the IP option might be
fraught with danger since, in certain cases, I believe, you just return
the incoming options in the outgoing packet (timewait, openreq, etc.?),
and there's no assurance that that's a valid enough option that you can
retrieve a sid with it, correct?
