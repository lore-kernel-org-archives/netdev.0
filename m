From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Make table id type u32
Date: Tue, 1 Sep 2015 11:56:34 -0700
Message-ID: <4331D545-E0BB-4F90-A691-55D8524CFA8F@cumulusnetworks.com>
References: <1441133416-29523-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36233 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753100AbbIAS4h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:56:37 -0400
Received: by pacwi10 with SMTP id wi10so4378250pac.3
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:56:37 -0700 (PDT)
In-Reply-To: <1441133416-29523-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Sep 1, 2015, at 11:50 AM, David Ahern <dsa@cumulusnetworks.com> wr=
ote:
>=20
> A number of VRF patches used 'int' for table id. It should be u32 to =
be
> consistent with the rest of the stack.
>=20
> Fixes:
> 4e3c89920cd3a ("net: Introduce VRF related flags and helpers")
> 15be405eb2ea9 ("net: Add inet_addr lookup by table")
> 30bbaa1950055 ("net: Fix up inet_addr_type checks")
> 021dd3b8a142d ("net: Add routes to the table associated with the devi=
ce")
> dc028da54ed35 ("inet: Move VRF table lookup to inlined function")
> f6d3c19274c74 ("net: FIB tracepoints")
>=20
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - update tracepoint as well (thanks, Nikolay)
>=20
> include/net/route.h        |  2 +-
> include/net/vrf.h          | 24 ++++++++++++------------
> include/trace/events/fib.h |  4 ++--
> net/ipv4/af_inet.c         |  2 +-
> net/ipv4/fib_frontend.c    | 10 +++++-----
> net/ipv4/fib_semantics.c   |  2 +-
> 6 files changed, 22 insertions(+), 22 deletions(-)
<<snip>>
> diff --git a/include/trace/events/fib.h b/include/trace/events/fib.h
> index acd1d22571a2..e9cea16d1515 100644
> --- a/include/trace/events/fib.h
> +++ b/include/trace/events/fib.h
> @@ -11,12 +11,12 @@
>=20
> TRACE_EVENT(fib_table_lookup,
>=20
> -	TP_PROTO(int tb_id, const struct flowi4 *flp),
> +	TP_PROTO(u32 tb_id, const struct flowi4 *flp),
>=20
> 	TP_ARGS(tb_id, flp),
>=20
> 	TP_STRUCT__entry(
> -		__field(	int,	tb_id		)
> +		__field(	u32,	tb_id		)
> 		__field(	int,	oif		)
> 		__field(	int,	iif		)
> 		__field(	__u8,	tos		)

I think you should update the TP_printk below as well, it=E2=80=99s tre=
ating it as a signed integer. :-)
