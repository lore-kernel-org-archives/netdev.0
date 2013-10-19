From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: net: sctp: possible dereference after freeing
Date: Sat, 19 Oct 2013 13:36:35 -0400
Message-ID: <DA7AE80C-302D-4B9D-9C0E-BA980E25DFCE@gmail.com>
References: <CAGG-pUTXC+6O-wyYp0FZxKH-XWqP++jLEn-Km5kixQFcKsWRZA@mail.gmail.com> <CAGG-pUT=qrYxOQ5jeU=9KipYO+MAA9oJj=241YMqo54S7K+xsA@mail.gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?utf-8?Q?Geyslan_Greg=C3=B3rio_Bem?= <geyslan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGG-pUT=qrYxOQ5jeU=9KipYO+MAA9oJj=241YMqo54S7K+xsA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Oct 19, 2013, at 7:49 AM, Geyslan Greg=C3=B3rio Bem <geyslan@gmail.c=
om> wrote:

> 2013/10/19 Geyslan Greg=C3=B3rio Bem <geyslan@gmail.com>:
>> Hi maintainers,
>>=20
>> I would like to know if these are catches:
>>=20
>> /net/sctp/endpointola.c (281)
>> static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>> {
>>    struct sock *sk;
>> ...
>>    kfree(ep);
>>    SCTP_DBG_OBJCNT_DEC(ep);
>> }
>>=20
>> The 'ep' object counter is being decremented?! Is the kfree to be th=
ere indeed?
>> Let me know what was intended here.
>>=20
>> Same here:
>> /net/sctp/endpointola.c (165)
>> static void sctp_transport_destroy_rcu(struct rcu_head *head)
>> {
>>    struct sctp_transport *transport;
>> ...
>>    kfree(transport);
>>    SCTP_DBG_OBJCNT_DEC(transport);
>> }
>>=20
>> Regards,
>>=20
>> Geyslan Greg=C3=B3rio Bem
>> hackingbits.com
>=20
> Oops. I got it. ;)
>=20
> extern atomic_t sctp_dbg_objcnt_ep;
> http://lxr.free-electrons.com/source/include/net/sctp/sctp.h#L269
> extern atomic_t sctp_dbg_objcnt_transport;
> http://lxr.free-electrons.com/source/arch/x86/include/asm/atomic.h#L1=
05
>=20
> Cheers.

There is no reference here since the macro turns variable name to strin=
g using ## name.
So the order doesn't matter really.

-vlad --
To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
