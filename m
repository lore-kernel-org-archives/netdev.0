From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH v2 net-next 0/6] add a set of tracepoints to tcp stack
Date: Mon, 23 Oct 2017 16:26:11 +0000
Message-ID: <1CE9BEAA-1678-47E2-AD6A-038388E3AEB1@fb.com>
References: <20171023162027.2880430-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "liu.song.a23@gmail.com" <liu.song.a23@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        "brendan.d.gregg@gmail.com" <brendan.d.gregg@gmail.com>,
        "ncardwell@google.com" <ncardwell@google.com>,
        David Ahern <dsahern@gmail.com>,
        Kernel Team <Kernel-team@fb.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50936 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751399AbdJWQ0W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:26:22 -0400
In-Reply-To: <20171023162027.2880430-1-songliubraving@fb.com>
Content-Language: en-US
Content-ID: <580A4B4C88E8384EBF2A2A7927CB82D0@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CCing key audience of these patches.

Thanks,
Song

> On Oct 23, 2017, at 9:20 AM, Song Liu <songliubraving@fb.com> wrote:
>=20
> Changes from v1:
>=20
> Fix build error (with ipv6 as ko) by adding EXPORT_TRACEPOINT_SYMBOL_GPL
> for trace_tcp_send_reset.
>=20
> These patches add the following tracepoints to tcp stack.
>=20
> tcp_send_reset
> tcp_receive_reset
> tcp_destroy_sock
> tcp_set_state
>=20
> These tracepoints can be used to track TCP state changes. Such state
> changes include but are not limited to: connection establish,
> connection termination, tx and rx of RST, various retransmits.
>=20
> Currently, we use the following kprobes to trace these events:
>=20
> int kprobe__tcp_validate_incoming
> int kprobe__tcp_send_active_reset
> int kprobe__tcp_v4_send_reset
> int kprobe__tcp_v6_send_reset
> int kprobe__tcp_v4_destroy_sock
> int kprobe__tcp_set_state
> int kprobe__tcp_retransmit_skb
>=20
> These tracepoints will help us simplify this work.
>=20
> Thanks,
> Song
>=20
> Song Liu (6):
>  tcp: add trace event class tcp_event_sk_skb
>  tcp: mark trace event arguments sk and skb as const
>  tcp: add tracepoint trace_tcp_send_reset
>  tcp: add tracepoint trace_tcp_receive_reset
>  tcp: add tracepoint trace_tcp_destroy_sock
>  tcp: add tracepoint trace_tcp_set_state()
>=20
> include/trace/events/tcp.h | 181 ++++++++++++++++++++++++++++++++++++++++=
++++-
> net/core/net-traces.c      |   2 +
> net/ipv4/tcp.c             |   4 +
> net/ipv4/tcp_input.c       |   3 +
> net/ipv4/tcp_ipv4.c        |   8 +-
> net/ipv4/tcp_output.c      |   5 ++
> net/ipv6/tcp_ipv6.c        |  10 ++-
> 7 files changed, 206 insertions(+), 7 deletions(-)
>=20
> --
> 2.9.5
