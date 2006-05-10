From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC][SECMARK 03/08] Add xtables SECMARK target
Date: Wed, 10 May 2006 08:03:31 +0200
Message-ID: <44618233.5020704@trash.net>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei> <Pine.LNX.4.64.0605071134250.8588@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52172 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964827AbWEJGDd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 02:03:33 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605071134250.8588@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> This patch adds a SECMARK target to xtables, allowing
> the admin to apply security marks to packets via both
> iptables and ip6tables.
> 
> The target currently handles SELinux security marking,
> but can be extended for other purposes as needed.

The netfilter parts all look fine too me (just one question,
see below). Shall I add the userspace parts to SVN or do you
want to do it yourself?


> +static int checkentry_selinux(struct xt_secmark_target_info *info)
> +{
> +	int err;
> +	struct xt_secmark_target_selinux_info *sel = &info->u.sel;
> +
> +	err = selinux_string_to_sid(sel->selctx, &sel->selsid);
> +	if (err) {
> +		if (err == -EINVAL)
> +			printk(KERN_INFO PFX "invalid SELinux context \'%s\'\n",
> +			       sel->selctx);
> +		return 0;
> +	}
> +	
> +	if (!sel->selsid) {
> +		printk(KERN_INFO PFX "unable to map SELinux context \'%s\'\n",
> +		       sel->selctx);
> +		return 0;
> +	}
> +
> +	return 1;
> +}

I wonder if the result of this check could be invalidated later
by removal of the selinux context and if it would matter, since
you reject contexts not known at initialization time.

