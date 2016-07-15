From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipmr/ip6mr: add support for keeping an entry age
Date: Fri, 15 Jul 2016 16:19:15 -0700
Message-ID: <5C88DC97-D16D-4E0F-9846-BFE9DA4625E3@cumulusnetworks.com>
References: <1468508930-32720-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Satish Ashok <sashok@cumulusnetworks.com>,
	Donald Sharp <sharpd@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36214 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbcGOXTU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:19:20 -0400
Received: by mail-pf0-f182.google.com with SMTP id t190so45154467pfb.3
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 16:19:19 -0700 (PDT)
In-Reply-To: <1468508930-32720-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jul 14, 2016, at 8:08 AM, Nikolay Aleksandrov <nikolay@cumulusnetw=
orks.com> wrote:
>=20
> In preparation for hardware offloading of ipmr/ip6mr we need an
> interface that allows to check (and later update) the age of entries.
> Relying on stats alone can show activity but not actual age of the en=
try,
> furthermore when there're tens of thousands of entries a lot of the
> hardware implementations only support "hit" bits which are cleared on
> read to denote that the entry was active and shouldn't be aged out,
> these can then be naturally translated into age timestamp and will be
> compatible with the software forwarding age. Using a lastuse entry do=
esn't
> affect performance because the entries in that cache line are written=
 to
> along with the age. Once an entry goes above the member size (32 bits=
) we
> keep it at UINT_MAX as we cannot afford to wrap it which will falsely=
 show
> that it was used recently. This is not supposed to happen as entries =
should
> be aged out in matter of minutes or seconds.
> Since all new users are encouraged to use ipmr via netlink, this is
> exported via the RTA_CACHEINFO attribute which has rta_lastuse entry.
>=20
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> CC: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> CC: Satish Ashok <sashok@cumulusnetworks.com>
> CC: Donald Sharp <sharpd@cumulusnetworks.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> CC: James Morris <jmorris@namei.org>
> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> CC: Patrick McHardy <kaber@trash.net>
> =E2=80=94

Self-NAK, I=E2=80=99ll send a revised v2 version using a single u32 att=
ribute (RTA_EXPIRES), no need to waste the space
right now. We=E2=80=99ll add more as we need them.

Sorry for the noise.

Cheers,
 Nik
