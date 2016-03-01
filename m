From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: lock ppp->flags in ppp_read() and ppp_poll()
Date: Tue, 01 Mar 2016 16:14:57 -0500 (EST)
Message-ID: <20160301.161457.2060844348418737617.davem@davemloft.net>
References: <c7c10511f505342837d57e9bb628fb145504f3e6.1456507305.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbcCAVO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 16:14:59 -0500
In-Reply-To: <c7c10511f505342837d57e9bb628fb145504f3e6.1456507305.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 26 Feb 2016 18:45:34 +0100

> @@ -443,9 +443,14 @@ static ssize_t ppp_read(struct file *file, char __user *buf,
>  			 * network traffic (demand mode).
>  			 */
>  			struct ppp *ppp = PF_TO_PPP(pf);
> +
> +			ppp_recv_lock(ppp);
>  			if (ppp->n_channels == 0 &&
> -			    (ppp->flags & SC_LOOP_TRAFFIC) == 0)
> +			    (ppp->flags & SC_LOOP_TRAFFIC) == 0) {
> +				ppp_recv_unlock(ppp);
>  				break;
> +			}

I agree with this change because these two tests much be done without either
of them changing meanwhile, so I'll apply this to 'net', thanks!
