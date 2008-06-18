From: Remi Denis-Courmont <rdenis@simphalempin.com>
Subject: Re: Killing =?UTF-8?Q?sk-=3Esk=5Fcallback=5Flock?=
Date: Wed, 18 Jun 2008 09:36:23 +0200
Message-ID: <3b69bab8b78510bb05552a2664b868ac@chewa.net>
References: <20080617.144041.38758483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pmullaney@novell.com, herbert@gondor.apana.org.au,
	GHaskins.WAL-1.WALTHAM@novell.com, chuck.lever@oracle.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:41450 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752983AbYFRHgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 03:36:25 -0400
In-Reply-To: <20080617.144041.38758483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


    Hello,=0D
=0D
On Tue, 17 Jun 2008 14:40:41 -0700 (PDT), David Miller=0D
<davem@davemloft.net> wrote:=0D
>> The task can go directly back into a wait. This will effectively yie=
ld 2=0D
>> wake ups per udp request-response.=0D
> =0D
> I made the mistake of assuming that a high performance threaded=0D
> networking application would use non-blocking operations and=0D
> select/poll/epoll, which is clearly not the case here.=0D
> =0D
> It's blocking in a recv() and this is woken up by a write space=0D
> extraneous wakeup.=0D
=0D
With UDP, I have consistently gotten significantly (IIRC around 30%) be=
tter=0D
results using plain recv()/send() on blocking sockets than=0D
poll()/recv()/send() on non-blocking sockets, on Linux, on the fast pat=
h.=0D
Of course, this assumes there is only one socket per thread. Namely, us=
ing=0D
my Teredo IPv6 userland implementation.=0D
=0D
You are surely in a better position than I can ever be as to explaining=
 why=0D
this is so, and how bad and wrong my approach may be. Nevertheless my g=
uess=0D
has been the system call overhead is simply higher when adding poll() t=
o=0D
recv() and send().=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net

