From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 1/3] Fix for IPsec leakage with SELinux enabled - V.03
Date: Thu, 5 Oct 2006 17:27:03 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CFB65@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>, paul.moore@hp.com,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	eparis@redhat.com, johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:50972 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S932225AbWJEV1V
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 17:27:21 -0400
To: David Miller <davem@davemloft.net>, jmorris@namei.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: James Morris <jmorris@namei.org>
> Date: Thu, 5 Oct 2006 16:54:38 -0400 (EDT)
> 
> > >  #ifdef CONFIG_XFRM_SUB_POLICY
> > >  	pol = xfrm_policy_lookup_bytype(XFRM_POLICY_TYPE_SUB, 
> fl, family, dir);
> > > -	if (pol)
> > > +	if (IS_ERR(pol)) {
> > > +		err = PTR_ERR(pol);
> > > +		pol = NULL;
> > > +	}
> > > +	if (pol || err)
> > >  		goto end;
> > 
> > Similarly, if the sub-policy lookup returns -EACCESS, 
> should we then try a 
> > main policy lookup before failing?
> 
> We're trying to fill the flow cache here.  In the case where we'd
> have a match in both the sub-policy and main table, I think the
> sub-policy is supposed to take precedence, and if you fail to get
> this sub-policy you should fail the entire lookup.

Which is what's happening here correct?

> 
> The way the sub-policied entries work is that you find the sub-policy
> as the primary object in the flow cache, and once you notice you have
> a sub-policy you do an explicit lookup in the main table to put the
> whole thing together.

May be James can help me understand this; when exactly would a sub-policy
be "notice"d here? What does "put the whole thing together" mean?
