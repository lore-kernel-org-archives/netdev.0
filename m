From: Chris Wright <chrisw@osdl.org>
Subject: Re: [RFC] SO_PEERSEC - security credentials for Unix stream sockets
Date: Fri, 12 Dec 2003 16:16:17 -0800
Sender: linux-security-module-bounces@wirex.com
Message-ID: <20031212161617.C24246@osdlab.pdx.osdl.net>
References: <Xine.LNX.4.44.0312101110010.27922-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
	linux-security-module@wirex.com,
	Stephen Smalley <sds@epoch.ncsc.mil>, netdev@oss.sgi.com
Return-path: <linux-security-module-bounces@wirex.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0312101110010.27922-100000@thoron.boston.redhat.com>;
	from jmorris@redhat.com on Wed, Dec 10, 2003 at 11:33:53AM -0500
List-Unsubscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=unsubscribe>
List-Archive: <http://mail.immunix.com/pipermail/linux-security-module>
List-Post: <mailto:linux-security-module@mail.wirex.com>
List-Help: <mailto:linux-security-module-request@mail.wirex.com?subject=help>
List-Subscribe: <http://mail.wirex.com/mailman/listinfo/linux-security-module>,
	<mailto:linux-security-module-request@mail.wirex.com?subject=subscribe>
Errors-To: linux-security-module-bounces@wirex.com
List-Id: netdev.vger.kernel.org

* James Morris (jmorris@redhat.com) wrote:
> Below is a patch against 2.6.0-test11 which implements a new socket option
> SO_PEERSEC (defined for i386 only at this stage).

Thanks for doing this James.  In your example demonstration, you simply
print the peersec string.  Do you expect to use with simple comparison
against something like data from procattr, or something else?  IOW,
does this introduce any new namespace issues for apps?

> +static inline int security_sk_alloc_security(struct sock *sk, int family, int priority)
> +static inline void security_sk_free_security(struct sock *sk)

minor nit.  these names are inconsistent with the existing analogous ones.
how about simply, security_sk_alloc and security_sk_free?

> +++ linux-2.6.0-test11.w2/net/core/sock.c	2003-12-10 09:55:39.378901360 -0500
> @@ -564,6 +564,9 @@
>  			v.val = sk->sk_state == TCP_LISTEN;
>  			break;
>  
> +		case SO_PEERSEC:
> +			return security_socket_getpeersec(sock, optval, len);
> +

Would it be useful to ask the module to update len as is done in some
other cases.  Perhaps buffer is too small, can len be vector for that info?

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
