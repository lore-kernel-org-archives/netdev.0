From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: clear RTF_EXPIRES when call ip6_rt_copy
Date: Tue, 17 Dec 2013 09:30:48 +0100
Message-ID: <20131217083048.GB18396@order.stressinduktion.org>
References: <1387182666-31301-1-git-send-email-roy.qing.li@gmail.com> <52AFC43C.9080804@cn.fujitsu.com> <CAJFZqHwF0ubvxJOs2BWbSMMB1szKNO=XTiXje3E2ByF6sUQrXA@mail.gmail.com> <52AFE7E3.3070806@cn.fujitsu.com> <CAJFZqHxawisUbHGZY8mjGHy8035X6TQ7FNzc20vtS5j1jdZYGA@mail.gmail.com> <20131217070231.GA11970@order.stressinduktion.org> <52B00150.3070002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: RongQing Li <roy.qing.li@gmail.com>, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60949 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab3LQIat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 03:30:49 -0500
Content-Disposition: inline
In-Reply-To: <52B00150.3070002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 03:46:24PM +0800, Gao feng wrote:
> > Gao, do you still remember why you used RTF_ADDRCONF|RTF_DEFAULT?
> >=20
>=20
> It's a mystery=EF=BC=8C I noticed this problem when I wrote the codes=
=2E
> http://lists.openwall.net/netdev/2012/03/19/7

I already found this thread, thanks. ;)

> I used the flags RTF_ADDRCONF|RTF_DEFAULT because they are exist in
> rt6_{get,add,purge}_dflt_router.

I thought so, but we have to deal with !DEFAULT ADDRCONF routes, too.

> The from of new cloned rt should not be set if it's impossible for th=
e ort
> to be expired.

Ok.

> but seems we should set from if flags have RTF_ADDRCONF bit. RA packa=
ge
> not only generate the default route.

Exactly, but it is worse:

Prefix routes can be added with expiration time if user space installs =
a
prefix with valid_lft !=3D infinity. So I fear we already have permamen=
t route
entries which expire.

Userspace router advertisment listener already use that.

I fear the flags don't have a well defined semantic any more. :(

As for the original patch in this thread, I would suggest to hold it
back until this mess is understood. Ok?

Thanks,

  Hannes
