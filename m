From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 15:38:32 +0200
Message-ID: <4A37A058.1030701@gmail.com>
References: <20090616094813.GA1686@elte.hu>	<20090616.025659.224075454.davem@davemloft.net>	<20090616101132.GA28204@elte.hu> <20090616.033554.102149558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mingo@elte.hu, alan@lxorguk.ukuu.org.uk,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47094 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbZFPNi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 09:38:56 -0400
In-Reply-To: <20090616.033554.102149558.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 16 Jun 2009 12:11:32 +0200
>=20
>> sure, here you go (i also added a stack dump, just in case it's some=
=20
>> kernel-internal socket open):
>>
>>  [ifconfig:3516]: Creates X25 socket.
>>
>> so plain ifconfig. Part of the ~1.5 years old net-tools-1.60-84.fc8.
>=20
> Ok, ifconfig seems to open one of every socket type when it starts up=
=2E
> That explains why an X25 socket is openned and then closed.
>=20
> Now the question is why is the X25 socket released by a timer?  This
> should only happen if some socket memory is still pending in the
> socket buffers.
>=20
> Wait, I know why this is triggering now.  It's Eric Dumazet's SKB
> accounting optimizations.
>=20
> So, I'll fix the X25 timer bug.  It's always been there, but
> beforehand this deferred-via-timer x25 socket destruction path almost
> never triggers.  So we never saw it.  Now it happens every time.
>=20
> Eric can you sniff around and see what you think about this unforseen
> (at least for me) consequence of your changes?  Socket layers that us=
e
> the current sk_wmem_alloc/sk_rmem_alloc value at destroy time to
> determine if a socket can be killed immediately, or need to be killed
> later via timer, will always see that dummy one byte allocation you
> now put there.
>=20
> Can you look into that?
>=20
> Thanks.


Sure I can look if a layer uses sk_wmem_alloc as you describe.

(I take you refer to commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 :
net: No more expensive sock_hold()/sock_put() on each tx)

So there is no impact for sk_rmem_alloc AFAIK

Thanks
