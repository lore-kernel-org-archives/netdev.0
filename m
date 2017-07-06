From: Dave Watson <davejwatson@fb.com>
Subject: Re: [PATCH v3 net-next 0/4] kernel TLS
Date: Thu, 6 Jul 2017 07:48:54 -0700
Message-ID: <20170706144854.GA96869@davejwatson-mba.dhcp.thefacebook.com>
References: <20170614183654.GA80067@davejwatson-mba.dhcp.thefacebook.com>
 <CAFLxGvz=OfvZ4uOggkZjN7KKM11dzUp6Sd2O76SP5Nu_8Ty1gA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        <nmav@gnutls.org>, <fridolin.pokorny@gmail.com>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39234 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751813AbdGFOtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2017 10:49:16 -0400
Content-Disposition: inline
In-Reply-To: <CAFLxGvz=OfvZ4uOggkZjN7KKM11dzUp6Sd2O76SP5Nu_8Ty1gA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard, 

On 07/06/17 04:30 PM, Richard Weinberger wrote:
> Dave,
> 
> On Wed, Jun 14, 2017 at 8:36 PM, Dave Watson <davejwatson@fb.com> wrote:
> >  Documentation/networking/tls.txt   | 135 +++++++
> >  MAINTAINERS                        |  10 +
> >  include/linux/socket.h             |   1 +
> >  include/net/inet_connection_sock.h |   4 +
> >  include/net/tcp.h                  |  27 ++
> >  include/net/tls.h                  | 237 ++++++++++++
> >  include/uapi/linux/tcp.h           |   1 +
> >  include/uapi/linux/tls.h           |  79 ++++
> >  net/Kconfig                        |   1 +
> >  net/Makefile                       |   1 +
> >  net/ipv4/Makefile                  |   2 +-
> >  net/ipv4/sysctl_net_ipv4.c         |  25 ++
> >  net/ipv4/tcp.c                     |  33 +-
> >  net/ipv4/tcp_ipv4.c                |   2 +
> >  net/ipv4/tcp_rate.c                |   1 +
> >  net/ipv4/tcp_ulp.c                 | 134 +++++++
> >  net/tls/Kconfig                    |  12 +
> >  net/tls/Makefile                   |   7 +
> >  net/tls/tls_main.c                 | 487 +++++++++++++++++++++++
> >  net/tls/tls_sw.c                   | 772 +++++++++++++++++++++++++++++++++++++
> >  20 files changed, 1968 insertions(+), 3 deletions(-)
> >  create mode 100644 Documentation/networking/tls.txt
> >  create mode 100644 include/net/tls.h
> >  create mode 100644 include/uapi/linux/tls.h
> >  create mode 100644 net/ipv4/tcp_ulp.c
> >  create mode 100644 net/tls/Kconfig
> >  create mode 100644 net/tls/Makefile
> >  create mode 100644 net/tls/tls_main.c
> >  create mode 100644 net/tls/tls_sw.c
> 
> Sorry for the late question. Do I miss something or is this IPv4 only?

The hooks it currently overrides / uses from proto_ops (sendmsg, sendpage,
get/setsockopt, close) are the same for ipv4 & ipv6, so it should work
for both.  Our test suites have been passing in both, at least.
