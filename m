From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] netfilter: nfnetlink_queue: add definition of	aligned_be64
 for user-space apps
Date: Thu, 15 Jul 2010 17:07:00 +0200
Message-ID: <4C3F2414.9090606@trash.net>
References: <20100712165241.4026.83949.stgit@decadence> <20100712170019.4026.55069.stgit@decadence> <4C3ED2A7.1090300@trash.net> <4C3EF819.8080801@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, NetDev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4C3EF819.8080801@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 15.07.2010 13:59, schrieb Pablo Neira Ayuso:
> On 15/07/10 11:19, Patrick McHardy wrote:
>> Am 12.07.2010 19:00, schrieb Pablo Neira Ayuso:
>>> Currently, libnl and libnetfilter_queue include in one of their
>>> user-space header files an ad-hoc definition of aligned_be64.
>>> However, applications that use the BSD socket API to communicate
>>> via Netlink sockets (ie. those that do not use these libraries)
>>> would need to define this type by hand if they include the
>>> kernel-space header nfnetlink_queue.h.
>>>
>>> This patch adds the definition of aligned_bed64 for user-space
>>> applications in the kernel header. Otherwise, they have to define
>>> it to avoid the following compilation problem:
>>>
>>> /usr/include/linux/netfilter/nfnetlink_queue.h:28: error: expected =
specifier-qualifier-list before =E2=80=98aligned_be64=E2=80=99
>>
>> Why can't these applications simply include linux/types.h?
>=20
> Including it doesn't fix the problem here:
>=20
> #include <linux/types.h>
> #include <linux/netfilter/nfnetlink_queue.h>
>=20
> I still get:
>=20
> /usr/include/linux/netfilter/nfnetlink_queue.h:28: error: expected
> specifier-qualifier-list before =E2=80=98aligned_be64=E2=80=99
>=20
> aligned_be64 is only define in the kernel (it's included under the
> __KERNEL__ definition).
>

In that case I think we should export a __aligned_be64 in types.h
and use that instead of aligned_be64.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
