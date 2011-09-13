From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCH] net: change capability used by socket options
 IP{,V6}_TRANSPARENT
Date: Tue, 13 Sep 2011 17:27:09 +0200
Message-ID: <1315927629.5851.4.camel@bzorp>
References: <1314953022.26692.182.camel@bzorp>
	 <1314990654-32252-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	netdev@vger.kernel.org
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq.balabit.com ([213.253.200.34]:48907 "EHLO mail.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754878Ab1IMP1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 11:27:14 -0400
In-Reply-To: <1314990654-32252-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-02 at 12:10 -0700, Maciej =C5=BBenczykowski wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> Up till now the IP{,V6}_TRANSPARENT socket options (which actually se=
t
> the same bit in the socket struct) have required CAP_NET_ADMIN
> privileges to set or clear the option.
>=20
> - we make clearing the bit not require any privileges.
> - we deprecate using CAP_NET_ADMIN for this purpose.
> - we introduce a new capability CAP_NET_TRANSPARENT,
>   which is tailored to allow setting just this bit.
> - we allow either one of CAP_NET_TRANSPARENT or CAP_NET_RAW
>   to set this bit, because raw sockets already effectively
>   allow you to emulate socket transparency, and make the
>   transition easier for apps not desiring to use a brand
>   new capability (because of header file or glibc support)
> - we print a warning (but allow it) if you try to set
>   the socket option with CAP_NET_ADMIN privs, but without
>   either one of CAP_NET_TRANSPARENT or CAP_NET_RAW.
>=20
> The reason for introducing a new capability is that while
> transparent sockets are potentially dangerous (and can let you
> spoof your source IP on traffic), they don't normally give you
> the full 'freedom' of eavesdropping and/or spoofing that raw sockets
> give you.
>=20
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> CC: Balazs Scheidler <bazsi@balabit.hu>

This is ok for me, as long as the security maintainers allow the
introduction of this new cap.

Thanks for doing this and sorry for the late reply.

Acked-by: Balazs Scheidler <bazsi@balabit.hu>

--=20
Bazsi
