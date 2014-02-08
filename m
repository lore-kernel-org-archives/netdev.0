From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] ipx: implement shutdown()
Date: Sun, 9 Feb 2014 00:17:43 +0100
Message-ID: <20140208231743.GB12704@kria>
References: <1391900669-880-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org, 00cpxxx@gmail.com
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:51160 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125AbaBHXRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Feb 2014 18:17:55 -0500
Content-Disposition: inline
In-Reply-To: <1391900669-880-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-09, 00:04:29 +0100, Sabrina Dubroca wrote:
> +static int ipx_shutdown(struct socket *sock, int mode)
> +{
> +	struct sock *sk = sock->sk;
> +
> +	printk(KERN_INFO "IPX: shutting down %d\n", mode);
> +	if (mode < SHUT_RD || mode > SHUT_RDWR)
> +		return -EINVAL;
> +	/* This maps:
> +	 * SHUT_RD   (0) -> RCV_SHUTDOWN  (1)
> +	 * SHUT_WR   (1) -> SEND_SHUTDOWN (2)
> +	 * SHUT_RDWR (2) -> SHUTDOWN_MASK (3)
> +	 */
> +	++mode;
> +
> +	lock_sock(sk);
> +	sk->sk_shutdown |= mode;
> +	release_sock(sk);
> +	sk->sk_state_change(sk);
> +	printk(KERN_INFO "IPX: socket shut down\n");
> +
> +	return 0;
> +}

Sorry, I sent the version with the debugging in. I'll resend a clean one.

-- 
Sabrina
