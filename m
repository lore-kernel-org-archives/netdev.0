From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 4/7 RFC] TCPCT part 1d: define TCP cookie
 option, extend existing struct's
Date: Fri, 13 Nov 2009 07:32:38 +0100
Message-ID: <4AFCFD86.6020504@gmail.com>
References: <4AFCDA9E.8050003@gmail.com> <4AFCE65C.2010104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52191 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbZKMGcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 01:32:35 -0500
In-Reply-To: <4AFCE65C.2010104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> Data structures are carefully composed to require minimal additions.
> For example, the struct tcp_options_received cookie_plus variable fit=
s
> between existing 16-bit and 8-bit variables, requiring no additional
> space (taking alignment into consideration).  There are no additions =
to
> tcp_request_sock, and only 1 pointer in tcp_sock.
>=20
> This is a significantly revised implementation of an earlier (year-ol=
d)
> patch that no longer applies cleanly, with permission of the original
> author (Adam Langley):
>=20
>    http://thread.gmane.org/gmane.linux.network/102586
>=20
> The principle difference is using a TCP option to carry the cookie no=
nce,
> instead of a user configured offset in the data.  This is more flexib=
le and
> less subject to user configuration error.  Such a cookie option has b=
een
> suggested for many years, and is also useful without SYN data, allowi=
ng
> several related concepts to use the same extension option.
>=20
>    "Re: SYN floods (was: does history repeat itself?)", September 9, =
1996.
>    http://www.merit.net/mail.archives/nanog/1996-09/msg00235.html
>=20
>    "Re: what a new TCP header might look like", May 12, 1998.
>    ftp://ftp.isi.edu/end2end/end2end-interest-1998.mail
>=20
> These functions will also be used in subsequent patches that implemen=
t
> additional features.
>=20
> Requires:
>   TCPCT part 1a: add request_values parameter for sending SYNACK
>   TCPCT part 1b: generate Responder Cookie
>   TCPCT part 1c: sysctl_tcp_cookie_size, socket option
> TCP_COOKIE_TRANSACTIONS
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  include/linux/tcp.h |   29 ++++++++++++++++----
>  include/net/tcp.h   |   72
> +++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 95 insertions(+), 6 deletions(-)
>=20

+/**
+ * A tcp_sock contains a pointer to the current value, and this is clo=
ned to
+ * the tcp_timewait_sock.
+ *
+ * @cookie_pair:	variable data from the option exchange.
+ *
+ * @cookie_desired:	user specified tcpct_cookie_desired.  Zero
+ *			indicates default (sysctl_tcp_cookie_size).
+ *			After cookie sent, remembers size of cookie.
+ *			Range 0, TCP_COOKIE_MIN to TCP_COOKIE_MAX.
+ *
+ * @s_data_desired:	user specified tcpct_s_data_desired.  When the
+ *			constant payload is specified (@s_data_constant),
+ *			holds its length instead.
+ *			Range 0 to TCP_MSS_DESIRED.
+ *
+ * @s_data_payload:	constant data that is to be included in the
+ *			payload of SYN or SYNACK segments when the
+ *			cookie option is present.
+ */

Thanks for this kerneldoc William ;)

But header should be :
/**
 *	struct tcp_cookie_values - Some description...


