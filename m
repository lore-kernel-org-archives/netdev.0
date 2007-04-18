From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
 send netlink message
Date: Wed, 18 Apr 2007 16:06:28 +0200
Message-ID: <462625E4.8030802@trash.net>
References: <461D26CB.3010508@trash.net>	 <1176400428.24446.40.camel@nt.wq.cz>	<4623029A.2090906@trash.net>	 <20070416.171016.43503207.davem@davemloft.net> <4624C46D.1030609@trash.net> <1176900487.8348.36.camel@nt.wq.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: =?ISO-8859-15?Q?Milan_Koci=E1n?= <milon@wq.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60308 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992551AbXDROHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 10:07:18 -0400
In-Reply-To: <1176900487.8348.36.camel@nt.wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milan Koci=E1n wrote:
> On Tue, 2007-04-17 at 14:58 +0200, Patrick McHardy wrote:
>=20
>>Milan, could you cook up another patch which uses NLM_F_REPLACE?
>=20
>=20
> I can try it. Output is in patch below. Review carefully. I don't kno=
w
> if it's best approach. It's tested and working without problem
> (probably :-))


Looks good, but your mailer corrupted long lines. Please resend as
attachment and sign off the patch.

> --- net/ipv4.old/fib_hash.c	2007-04-18 12:50:11.000000000 +0200
> +++ net/ipv4/fib_hash.c	2007-04-18 12:39:49.081369320 +0200
> @@ -443,7 +443,6 @@
>  		if (cfg->fc_nlflags & NLM_F_REPLACE) {
>  			struct fib_info *fi_drop;
>  			u8 state;
> -

And please drop this unrelated whitespace change.

> --- net/ipv4.old/fib_semantics.c	2007-04-18 12:50:11.000000000 +0200
> +++ net/ipv4/fib_semantics.c	2007-04-18 12:40:54.807377448 +0200
> @@ -301,7 +301,7 @@
>  }
> =20
>  void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
> -	       int dst_len, u32 tb_id, struct nl_info *info)
> +	       int dst_len, u32 tb_id, struct nl_info *info, unsigned int
> nlm_flags)

This should go on a new line since it exceeds 80 characters.

> --- net/ipv4.old/fib_lookup.h	2007-04-18 12:50:11.000000000 +0200
> +++ net/ipv4/fib_lookup.h	2007-04-18 12:43:42.377902856 +0200
> @@ -30,7 +30,7 @@
>  			 int dst_len, u8 tos, struct fib_info *fi,
>  			 unsigned int);
>  extern void rtmsg_fib(int event, __be32 key, struct fib_alias *fa,
> -		      int dst_len, u32 tb_id, struct nl_info *info);
> +		      int dst_len, u32 tb_id, struct nl_info *info, unsigned int
> nlm_flags);

Same here.
