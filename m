From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v4 11/14] selinux: Cache NetLabel secattrs in the
 socket's security struct
Date: Fri, 5 Sep 2008 19:12:02 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0809051909230.2526@tundra.namei.org>
References: <20080903003647.15669.45349.stgit@flek.lan> <20080903005005.15669.66676.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:58242 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752801AbYIEJMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 05:12:05 -0400
In-Reply-To: <20080903005005.15669.66676.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Sep 2008, Paul Moore wrote:

>  /**
> + * selinux_netlbl_sock_genattr - Generate the NetLabel socket secattr
> + * @sk: the socket
> + * @sid: the socket's SID
> + *
> + * Description:
> + * Generate the NetLabel security attributes for a socket, making full use of
> + * the socket's attribute cache.  Returns a pointer to the security attributes
> + * on success, negative values on failure.

Don't you mean NULL on failure?

> + *
> + */
> +static struct netlbl_lsm_secattr *selinux_netlbl_sock_genattr(struct sock *sk,
> +							      u32 sid)
> +{
> +	int rc;
> +	struct sk_security_struct *sksec = sk->sk_security;
> +	struct netlbl_lsm_secattr *secattr;
> +
> +	if (sksec->nlbl_secattr != NULL)
> +		return sksec->nlbl_secattr;
> +
> +	secattr = netlbl_secattr_alloc(GFP_ATOMIC);
> +	if (secattr == NULL)
> +		return NULL;
> +	rc = security_netlbl_sid_to_secattr(sid, secattr);
> +	if (rc != 0) {
> +		netlbl_secattr_free(secattr);
> +		return NULL;
> +	}
> +	sksec->nlbl_secattr = secattr;
> +
> +	return secattr;
> +}
> +

Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
