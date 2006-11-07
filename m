From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 3/3] mlsxfrm: Various fixes
Date: Tue, 07 Nov 2006 15:48:40 -0500
Message-ID: <1162932520.3009.58.camel@moss-spartans.epoch.ncsc.mil>
References: <4550BF9A.3040002@trustedcs.com>  <4550ECA4.70909@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:10674 "EHLO jazzhorn.ncsc.mil")
	by vger.kernel.org with ESMTP id S1753253AbWKGUto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 15:49:44 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <4550ECA4.70909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-11-07 at 15:29 -0500, Paul Moore wrote:
> Venkat Yekkirala wrote:
> > +/*
> > + * security_sid_compare() - compares two given sid contexts.
> > + * Returns 1 if they are equal, 0 otherwise.
> > + */
> > +int security_sid_compare(u32 sid1, u32 sid2)
> > +{
> > +	struct context *context1;
> > +	struct context *context2;
> > +	int rc;
> > +
> > +	if (!ss_initialized)
> > +		return 1;
> > +
> > +	if (sid1 == sid2)
> > +		return 1;
> > +	else if (sid1 > SECINITSID_NUM && sid2 > SECINITSID_NUM)
> > +		return 0;
> > +
> > +	/* explicit comparison in order */
> > +
> > +	POLICY_RDLOCK;
> > +	context1 = sidtab_search(&sidtab, sid1);
> > +	if (!context1) {
> > +		printk(KERN_ERR "security_sid_compare:  unrecognized SID "
> > +		       "%u\n", sid1);
> > +		rc = 0;
> > +		goto out_unlock;
> > +	}
> > +
> > +	context2 = sidtab_search(&sidtab, sid2);
> > +	if (!context2) {
> > +		printk(KERN_ERR "security_sid_compare:  unrecognized SID "
> > +		       "%u\n", sid2);
> > +		rc = 0;
> > +		goto out_unlock;
> > +	}
> > +
> > +	rc = context_cmp(context1, context2);
> > +
> > +out_unlock:
> > +	POLICY_RDUNLOCK;
> > +	return rc;
> > +}
> 
> I understand wanting a generic LSM interface to do secid token comparisons, but
> in the SELinux implementation of this function I think we can get away with only
> a simple "sid1 == sid2" since the security server shouldn't be creating
> duplicate SID/secid values for identical contexts, I think.  Did you run into
> something in testing that would indicate otherwise?

Such duplication can occur among the initial SIDs.  Not sure though when
that would apply here, and it would only apply if both SIDs were initial
SIDs.

-- 
Stephen Smalley
National Security Agency

