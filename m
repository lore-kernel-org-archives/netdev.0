From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Tue, 4 Aug 2009 14:57:02 -0500
Message-ID: <20090804195702.GE10275@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-6-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>,
	netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:38709 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089AbZHDT5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 15:57:15 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n74Jqtnr010279
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:52:55 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n74Jv5Yc213192
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:57:06 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n74Jv1Dx020804
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 13:57:04 -0600
Content-Disposition: inline
In-Reply-To: <1249331463-11887-6-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Dan Smith (danms@us.ibm.com):
> +static int sock_unix_checkpoint(struct ckpt_ctx *ctx,
> +			        struct socket *socket,
> +			        struct ckpt_hdr_socket *h)
> +{
> +	struct unix_sock *sk = unix_sk(socket->sk);
> +	struct unix_sock *pr = unix_sk(sk->peer);
> +	struct ckpt_hdr_socket_unix *un;
> +	int new;
> +	int ret = -ENOMEM;
> +
> +	if ((socket->sk->sk_state == TCP_LISTEN) &&
> +	    !skb_queue_empty(&socket->sk->sk_receive_queue)) {
> +		ckpt_write_err(ctx, "listening socket has unaccepted peers");
> +		return -EBUSY;
> +	}
> +
> +	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UNIX);
> +	if (!un)
> +		goto out;

...

> + out:
> +	ckpt_hdr_put(ctx, un);

This will cause a null deref trying to get ptr->len in ckpt_hdr_put().

-serge
