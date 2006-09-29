From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 7/7] secid reconciliation-v03: Enforcement for SELinux
Date: Fri, 29 Sep 2006 08:59:19 -0400
Message-ID: <1159534759.8496.1.camel@moss-spartans.epoch.ncsc.mil>
References: <451C85F4.7000406@trustedcs.com>  <451C9897.6030306@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:716 "EHLO jazzhorn.ncsc.mil")
	by vger.kernel.org with ESMTP id S1161066AbWI2M6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 08:58:19 -0400
To: Joshua Brindle <method@gentoo.org>
In-Reply-To: <451C9897.6030306@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 23:52 -0400, Joshua Brindle wrote:
> Venkat Yekkirala wrote:
> > <snip>
> > +
> > +	err = avc_has_perm(xfrm_sid, skb->secmark, SECCLASS_PACKET,
> > +					PACKET__FLOW_IN, NULL);
> > +	if (err)
> > +		goto out;
> > +
> > +	if (xfrm_sid) {
> > +		err = security_transition_sid(xfrm_sid, skb->secmark,
> > +						SECCLASS_PACKET, &trans_sid);
> > +		if (err)
> > +			goto out;
> > +
> >   
> I thought we weren't doing transitions to label packets anymore per the 
> conference call?

No, transitions are still part of the reconciliation process.  By
default, this just means that we end up with the xfrm_sid (which is what
you want).  But it allows us the freedom to define transitions on the
secmark label if desired, and those transitions can still yield subject
labels.

-- 
Stephen Smalley
National Security Agency

