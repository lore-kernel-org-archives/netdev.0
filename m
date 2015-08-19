From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH] lwtunnel: Fix the sparse warnings in fib_encap_match
Date: Wed, 19 Aug 2015 09:40:03 +0200
Message-ID: <20150819094003.65ff7185@griffin>
References: <1439969609-11189-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<fengguang.wu@intel.com>, <kbuild-all@01.org>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588AbbHSHkI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 03:40:08 -0400
In-Reply-To: <1439969609-11189-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2015 15:33:29 +0800, Ying Xue wrote:
> When CONFIG_LWTUNNEL config is not enabled, the lwtstate_free() is no=
t
> declared in lwtunnel.h at all. However, even in this case, the functi=
on
> is still referenced in fib_semantics.c so that there appears the
> following sparse warnings:
>=20
> net/ipv4/fib_semantics.c:553:17: error: undefined identifier 'lwtstat=
e_free'
>   CC      net/ipv4/fib_semantics.o
>   net/ipv4/fib_semantics.c: In function =E2=80=98fib_encap_match=E2=80=
=99:
>   net/ipv4/fib_semantics.c:553:3: error: implicit declaration of func=
tion =E2=80=98lwtstate_free=E2=80=99 [-Werror=3Dimplicit-function-decla=
ration]
>   cc1: some warnings being treated as errors
>   make[1]: *** [net/ipv4/fib_semantics.o] Error 1
>   make: *** [net/ipv4/fib_semantics.o] Error 2
>=20
> To eliminate the error, we define an empty function for lwtstate_free=
()
> in lwtunnel.h when CONFIG_LWTUNNEL is disabled.
>=20
> Fixes: df383e6240ef ("lwtunnel: fix memory leak")
> Cc: Jiri Benc <jbenc@redhat.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Acked-by: Jiri Benc <jbenc@redhat.com>

Thanks, you beat me to it.

This is for net-next.

 Jiri

--=20
Jiri Benc
