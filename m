From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 09:33:12 +0100
Message-ID: <4566AE48.70409@cosmosbay.com>
References: <11641265982190@2ka.mipt.ru>	<456621AC.7000009@redhat.com>	<45662522.9090101@garzik.org>	<45663298.7000108@redhat.com>	<45664160.6060504@cosmosbay.com> <20061124001412.371ec4e7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:55177 "EHLO
	gw1.cosmosbay.com") by vger.kernel.org with ESMTP id S1757654AbWKXId5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Nov 2006 03:33:57 -0500
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061124001412.371ec4e7.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton a =E9crit :
> On Fri, 24 Nov 2006 01:48:32 +0100
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>>> The alternative is the sorry state we have now.  In nscd, for insta=
nce,=20
>>> we have one single thread waiting for incoming connections and it t=
hen=20
>>> has to wake up a worker thread to handle the processing.  This is d=
one=20
>>> because we cannot "park" all threads in the accept() call since whe=
n a=20
>>> new connection is announced _all_ the threads are woken.  With the =
new=20
>>> event handling this wouldn't be the case, one thread only is woken =
and=20
>>> we don't have to wake worker threads.  All threads can be worker th=
reads.
>> Having one specialized thread handling the distribution of work to w=
orker=20
>> threads is better most of the time.
>=20
> It might be now.  Think "commodity 128-way".  Your single distributio=
n thread
> will run out of steam.
>=20
> What Ulrich is proposing is faster.  This is a new interface.  Let's =
design
> it to be fast.

Hum... I guess you didnt read my mail... I basically agree with Ulrich.

I just wanted to say that a fast application cannot rely only on a "let=
's park=20
N threads waiting for single event in this queue", and hope kernel will=
 be=20
smart for us.

Even with 128-ways, you still hit a central point of coordination (it c=
an be a=20
mutex in kevent code, a atomic uidx in userland, or whatever) for a 'ke=
vent=20
queue'. Once you paid the cache lines ping/pong, you wont be *fast*.

I wish *you* dont think of kevent of only dispatching HTTP 1.0 trivial =
web=20
requests.

Being able to direct a particular request on a particular CPU is certai=
nly=20
something that cannot be hardcoded in 'the new kevent interface'.

Eric
