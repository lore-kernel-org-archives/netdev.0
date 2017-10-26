From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH net-next] tcp: add tracepoint
 trace_tcp_retransmit_synack()
Date: Thu, 26 Oct 2017 23:50:06 +0000
Message-ID: <2552809E-4EBC-4F3D-94A4-41BE0ECB27C2@fb.com>
References: <201710261134.MUf5E7cp%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        Martin Lau <kafai@fb.com>, Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "liu.song.a23@gmail.com" <liu.song.a23@gmail.com>
To: kbuild test robot <lkp@intel.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57602 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751489AbdJZXuY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:50:24 -0400
In-Reply-To: <201710261134.MUf5E7cp%fengguang.wu@intel.com>
Content-Language: en-US
Content-ID: <795F5630671F254E9E07B237694A4B6A@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Oct 25, 2017, at 8:13 PM, kbuild test robot <lkp@intel.com> wrote:
>=20
> Hi Song,
>=20
> [auto build test WARNING on net-next/master]
>=20
> url:    https://github.com/0day-ci/linux/commits/Song-Liu/tcp-add-tracepo=
int-trace_tcp_retransmit_synack/20171026-010651
> reproduce:
>        # apt-get install sparse
>        make ARCH=3Dx86_64 allmodconfig
>        make C=3D1 CF=3D-D__CHECK_ENDIAN__
>=20
>=20
> sparse warnings: (new ones prefixed by >>)
>=20
>=20
> vim +281 include/trace/events/tcp.h
>=20
>   241=09
>   242		TP_PROTO(const struct sock *sk, const struct request_sock *req),
>   243=09
>   244		TP_ARGS(sk, req),
>   245=09
>   246		TP_STRUCT__entry(
>   247			__field(const void *, skaddr)
>   248			__field(const void *, req)
>   249			__field(__u16, sport)
>   250			__field(__u16, dport)
>   251			__array(__u8, saddr, 4)
>   252			__array(__u8, daddr, 4)
>   253			__array(__u8, saddr_v6, 16)
>   254			__array(__u8, daddr_v6, 16)
>   255		),
>   256=09
>   257		TP_fast_assign(
>   258			struct inet_request_sock *ireq =3D inet_rsk(req);
>   259			struct in6_addr *pin6;
>   260			__be32 *p32;
>   261=09
>   262			__entry->skaddr =3D sk;
>   263			__entry->req =3D req;
>   264=09
>   265			__entry->sport =3D ireq->ir_num;
>   266			__entry->dport =3D ntohs(ireq->ir_rmt_port);
>   267=09
>   268			p32 =3D (__be32 *) __entry->saddr;
>   269			*p32 =3D ireq->ir_loc_addr;
>   270=09
>   271			p32 =3D (__be32 *) __entry->daddr;
>   272			*p32 =3D ireq->ir_rmt_addr;
>   273=09
>> 274	#if IS_ENABLED(CONFIG_IPV6)
>   275			if (sk->sk_family =3D=3D AF_INET6) {
>   276				pin6 =3D (struct in6_addr *)__entry->saddr_v6;
>   277				*pin6 =3D ireq->ir_v6_loc_addr;
>   278				pin6 =3D (struct in6_addr *)__entry->daddr_v6;
>   279				*pin6 =3D ireq->ir_v6_rmt_addr;
>   280			} else
>> 281	#endif

In this case, we are putting CONFIG_IPV6 in TRACE_EVENT macro, which genera=
tes
warnings like:

./include/trace/events/tcp.h:274:1: error: directive in argument list
./include/trace/events/tcp.h:281:1: error: directive in argument list

Seems these warning cannot be easily avoided. This is also the same pattern=
 we=20
have been using in include/trace/events/tcp.h.=20

Any suggestions on how shall we proceed from here?

Thanks,
Song
