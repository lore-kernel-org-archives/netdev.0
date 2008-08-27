From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Wed, 27 Aug 2008 16:51:42 -0300
Message-ID: <20080827165142.4bc7b70f@tux>
References: <20080819213417.45133573@tux>
	<Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
	<20080822183224.2d52f16c@tux>
	<20080822.143709.65615512.davem@davemloft.net>
	<20080823111446.06a350a2@tux>
	<Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
	<20080826181731.4581fd2c@tux>
	<Pine.LNX.4.64.0808271236080.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.245]:29331 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbYH0TwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 15:52:11 -0400
Received: by hs-out-0708.google.com with SMTP id 4so15456hsl.5
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 12:52:10 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0808271236080.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Aug 2008 13:22:22 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> ...thus there could be other ports that are related as well, do you=20
> remember what exactly started working in that particular case :-)?

> Which of the connections? Mail, nntp, ftp, or the etc.? :-) To the ho=
st ip=20
> which was given for the tcpdump filter, definately nothing was resume=
d.

	Ok. Let's focus on mail:

1) first, my client (Claws-mail -- but it happened with Outlook of
other users too) is working perfectly. I can download new messages. It
connects to port 995 on the server without problems.

2) suddenly it gives me an error message, that it cannot authenticate
anymore (sorry, I don't have the exact message). If I try again to
download new messages, it gives the same error. The connection to port
995 seems stalled or, better yet, cannot complete succesfully. It seems
to time out.

3) the server will stay this way, until I do an "nmap" to the server.
This way, everything goes back to normal.

	So, the server at point 2 got stalled and just an nmap server
can force the server to go back to normal behaviour (I discovered that
nmap solved the issue by luck).

> I was think that at a time (even thought of enquiring you about this=20
> part of the config), but the tcpdump log shows a problem that is=20
> unlikely to depend on timers in any way (and at least some timer expi=
res=20
> because the SYNACKs are retransmitted, so it's not in some infinite w=
ait=20
> bug). I'd like to know what causes that and try to solve it.

	Ok.

> Once we know the reasons, we can probably easily determinate whether=20
> there's need to experiment with the timers. Trying to conquer all pro=
blems=20
> at once, when not even knowing how many problems one is going to find=
 is=20
> not that easy either. Besides, I'd be more concerned about the timers=
 on=20
> the client after seeing that nothing goes in the network while the nm=
ap=20
> trick resolves the thing.

	Ok.

> The server's log captured not only 995 traffic but everything else to=
 the=20
> host with the given ip (including udp which should show the tunnelled=
=20
> traffic I guess). Unless there's some other route to that host with=20
=09
	Ok, that's because I forgot to restrict traffic to port 995 on
the server. Sorry.

> This makes me wander if the network behavior is at all related to=20
> resolving of the problem. Only thing I can think of is that for some=20
> reason the userspace gets notified much later than it should about
> TCP reset and therefore is waiting until that happens and can only
> then continue.

	What I can assure you is that other users (which use Microsoft
Outlook Express) had the same problem, so, in this case, we can be
pretty sure it isn't related to user space client.

> It would be too easy explanation, yeah :-). Can you still please chec=
k=20
> next time that there aren't even near that many server processes at t=
he=20
> server :-).

	Ok, when I get the problem I'll check this.

> Adding this wouldn't hurt btw:
>=20
> cat /proc/net/tcp

	Ok.

--=20
