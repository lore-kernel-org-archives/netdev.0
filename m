From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] tcp: more documentation for tcp_tw_reuse and tcp_tw_recycle
Date: Wed, 07 May 2014 21:55:49 +0200
Message-ID: <m3eh058it6.fsf@neo.luffy.cx>
References: <1399196499-8449-1-git-send-email-vincent@bernat.im>
	<1399196499-8449-2-git-send-email-vincent@bernat.im>
	<20140507.151637.562958118271192092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, linux-doc@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140507.151637.562958118271192092.davem@davemloft.net> (David
	Miller's message of "Wed, 07 May 2014 15:16:37 -0400 (EDT)")
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 =E2=9D=A6  7 mai 2014 15:16 -0400, David Miller <davem@davemloft.net>=C2=
=A0:

>> The documentation is not very helpful about what those settings
>> affect. We find numerous tuning guides advising to set both these
>> settings to 1 to reduce the number of entries in the TIME-WAIT
>> state. However, enabling tcp_tw_recycle will cause massive problems =
when
>> working with NAT.
>>=20
>> The documentation is completed a bit to explain quickly what kind of
>> connections both those settings will affect and to encourage the use=
 of
>> tcp_tw_reuse instead of tcp_tw_recycle for outgoing connections.
>
> First of all your change locks a proper signoff.

Sorry for that. I'll resend once the other problem is fixed.

> Second of all, both options can cause problems in the presence of NAT
> because both optimizations assume unique IP addresses identify unique
> physical hosts.

If NAT is done at the remote end (the outgoing connection is to some
load-balanced VIP) and if a TW state is reused for another
host than the original host, this can be one of those cases:

 1. There was no prior connection to the other host, so no problem.
=20
 2. There was a prior connection to this host and the TW state has
    properly expired (60-second regular timeout), no problem.
=20
 3. There was a prior connection to this host and the TW state has been
    reused previously, so we are already in the right condition
    (timestamps) to do the same thing.

I don't see a scenario where NAT can be a problem with tcp_tw_reuse.

If the NAT is done on the local end (we are behind a NAT device), as th=
e
TW is on our side, I don't see what problem could have the remote end
which has properly closed the connection. Even without tcp_tw_reuse, th=
e
remote side could get a legit connection from another local host.

We could be on the safe side and say that both settings may interact
badly with NAT gateways (or any altering gateways), but in this case,
both settings will look the same and the documentation will be as
unhelpful as it is now to someone which insists on using those settings=
=2E
--=20
 /* After several hours of tedious analysis, the following hash
  * function won.  Do not mess with it... -DaveM
  */
	2.2.16 /usr/src/linux/fs/buffer.c
