From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 11/16] netlabel: Add functionality to set the
 security attributes of a packet
Date: Wed, 1 Oct 2008 19:55:49 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810011952100.6732@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125701.17132.46623.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080916125701.17132.46623.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Sep 2008, Paul Moore wrote:

> This patch builds upon the new NetLabel address selector functionality by
> providing the NetLabel KAPI and CIPSO engine support needed to enable the
> new packet-based labeling.  The only new addition to the NetLabel KAPI at
> this point is shown below:
> 
>  * int netlbl_skbuff_setattr(skb, family, secattr)
> 
> ... and is designed to be called from a Netfilter hook after the packet's
> IP header has been populated such as in the FORWARD or LOCAL_OUT hooks.
> 
> This patch also provides the necessary SELinux hooks to support this new
> functionality.  Smack support is not currently included due to uncertainty
> regarding the permissions needed to expand the Smack network access controls.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Reviewed-by: James Morris <jmorris@namei.org>

> +	/* we overwrite any existing options to ensure that we have enough
> +	 * room for the CIPSO option, the reason is that we _need_ to guarantee
> +	 * that the security label is applied to the packet - we do the same
> +	 * thing when using the socket options and it hasn't caused a problem,
> +	 * if we need to we can always revisit this choice later */

....

> +	/* we have to do the following because we are being called from a
> +	 * netfilter hook which means the packet already has had the header
> +	 * fields populated and the checksum calculated - yes this means we
> +	 * are doing more work than needed but we do it to keep the core
> +	 * stack clean and tidy */

It might be better in the long term to integrate this stuff more directly 
with the core networking.



- James
-- 
James Morris
<jmorris@namei.org>
