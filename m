From: =?UTF-8?Q?Geyslan_Greg=C3=B3rio_Bem?= <geyslan@gmail.com>
Subject: Re: net: sctp: possible dereference after freeing
Date: Sat, 19 Oct 2013 08:49:10 -0300
Message-ID: <CAGG-pUT=qrYxOQ5jeU=9KipYO+MAA9oJj=241YMqo54S7K+xsA@mail.gmail.com>
References: <CAGG-pUTXC+6O-wyYp0FZxKH-XWqP++jLEn-Km5kixQFcKsWRZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGG-pUTXC+6O-wyYp0FZxKH-XWqP++jLEn-Km5kixQFcKsWRZA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/10/19 Geyslan Greg=C3=B3rio Bem <geyslan@gmail.com>:
> Hi maintainers,
>
> I would like to know if these are catches:
>
> /net/sctp/endpointola.c (281)
> static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
> {
>     struct sock *sk;
> ...
>     kfree(ep);
>     SCTP_DBG_OBJCNT_DEC(ep);
> }
>
> The 'ep' object counter is being decremented?! Is the kfree to be the=
re indeed?
> Let me know what was intended here.
>
> Same here:
> /net/sctp/endpointola.c (165)
> static void sctp_transport_destroy_rcu(struct rcu_head *head)
> {
>     struct sctp_transport *transport;
> ...
>     kfree(transport);
>     SCTP_DBG_OBJCNT_DEC(transport);
> }
>
> Regards,
>
> Geyslan Greg=C3=B3rio Bem
> hackingbits.com

Oops. I got it. ;)

extern atomic_t sctp_dbg_objcnt_ep;
http://lxr.free-electrons.com/source/include/net/sctp/sctp.h#L269
extern atomic_t sctp_dbg_objcnt_transport;
http://lxr.free-electrons.com/source/arch/x86/include/asm/atomic.h#L105

Cheers.
