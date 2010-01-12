From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: tcp_header_len_th and tcp_option_len_th
Date: Tue, 12 Jan 2010 11:40:30 +0100
Message-ID: <4B4C519E.2090207@gmail.com>
References: <4B44FE3C.6060809@gmail.com> <4B450065.4010108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46628 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751648Ab0ALKkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 05:40:35 -0500
In-Reply-To: <4B450065.4010108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/01/2010 22:28, William Allen Simpson a =E9crit :
> Redefine two TCP header functions to accept TCP header pointer.
> When subtracting, return signed int to allow error checking.
>=20
> These functions will be used in subsequent patches that implement
> additional features.
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  include/linux/tcp.h |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
>=20

Its better to inline your patches so that we can comment them, without =
copy/paste

When I hit 'reply to', my mailer only quoted the ChangeLog, not the pat=
ch.

Anyway ..

+/* Length of standard options only.  This could be negative. */
+static inline int tcp_option_len_th(const struct tcphdr *th)
+{
+	return (int)(th->doff * 4) - sizeof(*th);
+}


The (int) cast is not necessary, since the function returns a signed in=
t

->
	return th->doff * 4 - sizeof(*th);
