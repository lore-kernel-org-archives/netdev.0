From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Phonet: sockets list through proc_fs
Date: Mon, 20 Jul 2009 11:05:05 +0200
Message-ID: <4A643341.9090604@gmail.com>
References: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34677 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbZGTJFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 05:05:12 -0400
In-Reply-To: <1248078849-7343-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=C3=A9mi Denis-Courmont a =C3=A9crit :
> From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20

> +static int pn_sock_seq_show(struct seq_file *seq, void *v)
> +{
> +	int len;
> +
> +	if (v =3D=3D SEQ_START_TOKEN)
> +		seq_printf(seq, "%s%n", "pt  loc  rem rs st tx_queue rx_queue "
> +			"  uid inode ref pointer drops", &len);
> +	else {
> +		struct sock *sk =3D v;
> +		struct pn_sock *pn =3D pn_sk(sk);
> +
> +		seq_printf(seq, "%2d %04X:%04X:%02X %02X %08X:%08X %5d %lu "
> +			"%d %p %d%n",
> +			sk->sk_protocol, pn->sobject, 0, pn->resource,
> +			sk->sk_state,
> +			atomic_read(&sk->sk_wmem_alloc),
> +			atomic_read(&sk->sk_rmem_alloc),

Please use sk_wmem_alloc_get(sk) and  sk_rmem_alloc_get(sk)

> +			sock_i_uid(sk), sock_i_ino(sk),
> +			atomic_read(&sk->sk_refcnt), sk,
> +			atomic_read(&sk->sk_drops), &len);
> +	}
> +	seq_printf(seq, "%*s\n", 127 - len, "");
> +	return 0;
> +}
