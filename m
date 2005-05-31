From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH 2/2] Resend: LSM-IPSec Networking Hooks
Date: Tue, 31 May 2005 00:15:47 -0400 (EDT)
Message-ID: <Xine.LNX.4.44.0505310006060.28060-100000@thoron.boston.redhat.com>
References: <1116361671.5560.125.camel@dyn9002018177.watson.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <chrisw@osdl.org>, <serue@us.ibm.com>,
        <latten@austin.ibm.com>, <sds@tycho.nsa.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: jaegert <jaegert@us.ibm.com>
In-Reply-To: <1116361671.5560.125.camel@dyn9002018177.watson.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 May 2005, jaegert wrote:

Ok, my last review in this iteration.

> @@ -984,6 +1029,13 @@ static struct xfrm_state * pfkey_msg2xfr
>                x->lft.soft_add_expires_seconds = lifetime->sadb_lifetime_addtime;
>                x->lft.soft_use_expires_seconds = lifetime->sadb_lifetime_usetime;
>        }
> +
> +       sec_ctx = (struct sadb_x_sec_ctx *) ext_hdrs[SADB_X_EXT_SEC_CTX-1];
> +       if (sec_ctx != NULL) {
> +               if (security_xfrm_state_alloc(x, sec_ctx))
> +                       goto out;

You should propagate the return value of security_xfrm_state_alloc() here 
by assigning it to err.

> -selinux-y := avc.o hooks.o selinuxfs.o netlink.o nlmsgtab.o
> +selinux-y := avc.o hooks.o selinuxfs.o netlink.o nlmsgtab.o nethooks.o

What about making nethooks.o (or whatever it'll be called) conditionally 
compiled via CONFIG_SECURITY_NETWORK_XFRM ? (see netif.o)


> + * ISSUES:
> + *   1. Caching packets, so they are not dropped during negotiation

This needs to be done for IPsec in general, not sure what the status is.

> + *   2. Emulating a reasonable SO_PEERSEC across machines

This may not be too difficult if we limit this to connected TCP sockets.  

> + *   3. Testing sk_policy setting with context

What does this mean?


Overall, this looks like a really good approach to the problem.


- James
-- 
James Morris
<jmorris@redhat.com>
