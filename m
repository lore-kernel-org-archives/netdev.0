From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 3/3] mlsxfrm: Various fixes
Date: Tue, 07 Nov 2006 15:29:24 -0500
Message-ID: <4550ECA4.70909@hp.com>
References: <4550BF9A.3040002@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:35780 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1753132AbWKGU31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 15:29:27 -0500
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <4550BF9A.3040002@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala wrote:
> +/*
> + * security_sid_compare() - compares two given sid contexts.
> + * Returns 1 if they are equal, 0 otherwise.
> + */
> +int security_sid_compare(u32 sid1, u32 sid2)
> +{
> +	struct context *context1;
> +	struct context *context2;
> +	int rc;
> +
> +	if (!ss_initialized)
> +		return 1;
> +
> +	if (sid1 == sid2)
> +		return 1;
> +	else if (sid1 > SECINITSID_NUM && sid2 > SECINITSID_NUM)
> +		return 0;
> +
> +	/* explicit comparison in order */
> +
> +	POLICY_RDLOCK;
> +	context1 = sidtab_search(&sidtab, sid1);
> +	if (!context1) {
> +		printk(KERN_ERR "security_sid_compare:  unrecognized SID "
> +		       "%u\n", sid1);
> +		rc = 0;
> +		goto out_unlock;
> +	}
> +
> +	context2 = sidtab_search(&sidtab, sid2);
> +	if (!context2) {
> +		printk(KERN_ERR "security_sid_compare:  unrecognized SID "
> +		       "%u\n", sid2);
> +		rc = 0;
> +		goto out_unlock;
> +	}
> +
> +	rc = context_cmp(context1, context2);
> +
> +out_unlock:
> +	POLICY_RDUNLOCK;
> +	return rc;
> +}

I understand wanting a generic LSM interface to do secid token comparisons, but
in the SELinux implementation of this function I think we can get away with only
a simple "sid1 == sid2" since the security server shouldn't be creating
duplicate SID/secid values for identical contexts, I think.  Did you run into
something in testing that would indicate otherwise?

-- 
paul moore
linux security @ hp
