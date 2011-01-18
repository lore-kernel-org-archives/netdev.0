From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_unix: implement socket filter
Date: Tue, 18 Jan 2011 18:22:41 +0100
Message-ID: <1295371361.3290.15.camel@edumazet-laptop>
References: <1295368755-20931-1-git-send-email-ian.molton@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, ebiederm@xmission.com, xemul@openvz.org,
	davidel@xmailserver.org,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: Ian Molton <ian.molton@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295368755-20931-1-git-send-email-ian.molton@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 janvier 2011 =C3=A0 16:39 +0000, Ian Molton a =C3=A9crit :
> From: Alban Crequy <alban.crequy@collabora.co.uk>
>=20
> Linux Socket Filters can already be successfully attached and detache=
d on unix
> sockets with setsockopt(sockfd, SOL_SOCKET, SO_{ATTACH,DETACH}_FILTER=
, ...).
> See: Documentation/networking/filter.txt
>=20
> But the filter was never used in the unix socket code so it did not w=
ork. This
> patch uses sk_filter() to filter buffers before delivery.
>=20
> This short program demonstrates the problem on SOCK_DGRAM.


Any idea on performance cost adding sk_filter() call ?

Hmm, looking at it, I have no idea why sk_filter() needs to block BH.

I'll send a patch to relax this requirement.
