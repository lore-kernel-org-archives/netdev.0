From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: Fix sock freeing before sock_init_data() with
	__sk_free()
Date: Mon, 31 Aug 2009 06:36:49 +0000
Message-ID: <20090831063648.GB5005@ff.dom.local>
References: <20090830222340.GA17454@ami.dom.local> <4A9B6D23.9090505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:52386 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498AbZHaGgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 02:36:53 -0400
Received: by fxm17 with SMTP id 17so2574227fxm.37
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 23:36:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A9B6D23.9090505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 08:26:43AM +0200, Eric Dumazet wrote:
> Jarek Poplawski a =E9crit :
> > After recent changes sk_free() frees socks conditionally and depend=
s
> > on sk_wmem_alloc beeing set e.g. in sock_init_data(). But in some
> > cases sk_free() is called earlier, usually after other alloc errors=
=2E
> > This patch fixes it by exporting and using __sk_free() directly.
=2E..
> Very nice catch Jarek, but dont you think it would be cleaner to make=
 sure
> we can call sk_free() right after sk_alloc() instead, and not exporti=
ng
> __sk_free() ?
>=20
> ie initialize wmem_alloc in sk_alloc() instead of initializing it in=20
> sock_init_data() ?
>=20

Most probably it should be better. But I meant this fix for -net and
didn't wan't to break too much... So, if you're sure it's OK feel free
to send your version. (Or it could be changed like this in the -next.)

Jarek P.
