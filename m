From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: properly release md5sig_pool references
Date: Mon, 26 Sep 2011 08:26:09 +0200
Message-ID: <1317018369.2853.16.camel@edumazet-laptop>
References: <4E7FE4DD.5070804@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	yoshfuji@linux-ipv6.org
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43051 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab1IZG0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 02:26:14 -0400
Received: by wwf22 with SMTP id 22so6277983wwf.1
        for <netdev@vger.kernel.org>; Sun, 25 Sep 2011 23:26:13 -0700 (PDT)
In-Reply-To: <4E7FE4DD.5070804@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 septembre 2011 =C3=A0 10:35 +0800, Yan, Zheng a =C3=A9crit =
:
> tcp_v4_md5_do_add() increases use count of md5sig_pool by one for
> each tcp md5sig peer, so we should call tcp_free_md5sig_pool() for
> each peer when destroying the socket.
>=20
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>

As managing the use count is rather expensive, I think it would be
better to hold a single reference instead of multiple ones ?
