From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] allow ip_tables.h to be used from userspace
Date: Tue, 5 Dec 2006 10:46:22 -0800
Message-ID: <20061205104622.7b86182e@freekitty>
References: <20061205102927.4f1ef22f@freekitty>
	<4575BC9D.8070900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:36932 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968594AbWLESqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 13:46:36 -0500
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4575BC9D.8070900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 05 Dec 2006 19:38:21 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > The xtables version of ip_tables.h was no longer usable (in sanitized form)
> > by iproute2 and other applications because sparse annotations had crept
> > in.
> > 
> > @@ -194,7 +194,7 @@ struct ipt_replace
> >  	/* Number of counters (must be equal to current number of entries). */
> >  	unsigned int num_counters;
> >  	/* The old entries' counters. */
> > -	struct xt_counters __user *counters;
> > +	struct xt_counters *counters;
> 
> # Eliminate the contents of (and inclusions of) compiler.h
> 
> 
> HDRSED  := sed  -e "s/ inline / __inline__ /g" \
>                 -e "s/[[:space:]]__user[[:space:]]\+/ /g" \
>                 -e "s/(__user[[:space:]]\+/ (/g" \
> 
> I think this regex should be fixed instead to get rid of it
> while sanitizing (Makefile.headersinst).
> 

But ip_tables.h should still put include of compiler.h inside #ifdef __KERNEL__

-- 
Stephen Hemminger <shemminger@osdl.org>
