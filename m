From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Wed, 7 Oct 2009 12:19:07 -0500
Message-ID: <20091007171907.GA20572@us.ibm.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>
	<1254932945-12578-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, John Dykstra <jdykstra72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254932945-12578-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> This patch adds basic support for C/R of open INET sockets.  I think that
> all the important bits of the TCP and ICSK socket structures is saved,
> but I think there is still some additional IPv6 stuff that needs to be
> handled.
> 
> With this patch applied, the following script can be used to demonstrate
> the functionality:
> 
>   https://lists.linux-foundation.org/pipermail/containers/2009-October/021239.html
> 
> It shows that this enables migration of a sendmail process with open
> connections from one machine to another without dropping.

neato

> Now that listening socket support is in the c/r tree, I think it is
> a good time to start fielding comments and suggestions on the
> connected part, as I think lots of folks have input on how to make it
> better, safer, etc.

One thing:

> +static int sock_inet_cptrst(struct ckpt_ctx *ctx,
> +			    struct sock *sock,
> +			    struct ckpt_hdr_socket_inet *hh,
> +			    int op)
> +{
> +	struct inet_sock *sk = inet_sk(sock);
> +	struct inet_connection_sock *icsk = inet_csk(sock);
> +	int ret;
> +
> +	CKPT_COPY(op, hh->daddr, sk->daddr);
> +	CKPT_COPY(op, hh->rcv_saddr, sk->rcv_saddr);
> +	CKPT_COPY(op, hh->dport, sk->dport);
> +	CKPT_COPY(op, hh->num, sk->num);
> +	CKPT_COPY(op, hh->saddr, sk->saddr);
> +	CKPT_COPY(op, hh->sport, sk->sport);

This becomes an easy way around CAP_NET_BIND_SERVICE right?  Or
will that be caught by something already done in your listen
patch after this step?

thanks,
-serge
