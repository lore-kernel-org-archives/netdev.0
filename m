From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH 2/9] secid reconciliation-v04: Add LSM hooks
Date: Mon, 02 Oct 2006 12:40:06 -0400
Message-ID: <1159807206.6855.63.camel@moss-spartans.epoch.ncsc.mil>
References: <45203288.9060500@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mummy.ncsc.mil ([144.51.88.129]:1429 "EHLO jazzhorn.ncsc.mil")
	by vger.kernel.org with ESMTP id S965079AbWJBQjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 12:39:43 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <45203288.9060500@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-10-01 at 16:26 -0500, Venkat Yekkirala wrote:
> Add skb_policy_check and skb_netfilter_check hooks to LSM to enable
> reconciliation of the various security identifiers as well as enforce
> flow control on inbound (PREROUTING/INPUT) and outbound (OUTPUT/FORWARD/POSTROUTING)
> traffic.
> 
> Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>
> ---
>  include/linux/security.h |   41 ++++++++++++++++++++++++++++++++++++-
>  security/dummy.c         |   13 +++++++++++
>  2 files changed, 53 insertions(+), 1 deletion(-)

> @@ -3150,7 +3185,11 @@ static inline int security_xfrm_state_al
>  {
>  	if (!polsec)
>  		return 0;
> -	return security_ops->xfrm_state_alloc_security(x, NULL, polsec, secid);
> +	/*
> +	 * No need to pass polsec along since we want the context to be
> +	 * taken from secid which is usually from the sock.
> +	 */
> +	return security_ops->xfrm_state_alloc_security(x, NULL, NULL, secid);
>  }

As a follow-up patch, you could then drop polsec from the hook interface
in security_ops (but not the static inline function interface), and from
the underlying selinux functions.  That would simplify
selinux_xfrm_sec_ctx_alloc() a bit and make the logic clearer.

-- 
Stephen Smalley
National Security Agency

