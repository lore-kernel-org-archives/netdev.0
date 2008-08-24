From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Sun, 24 Aug 2008 16:38:43 -0300
Message-ID: <20080824163843.33b4f890@tux>
References: <20080819213417.45133573@tux>
 <Pine.LNX.4.64.0808201358490.4551@wrl-59.cs.helsinki.fi>
 <20080822183224.2d52f16c@tux>
 <20080822.143709.65615512.davem@davemloft.net>
 <20080823111446.06a350a2@tux>
 <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 23 Aug 2008 17:38:32 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Thanks for verifying it!

	Ops! i replied too fast! I just got a stalled connection again!

	Important: these files were generated with the HTB patches applied.

	Here are botch tcpdump files:

http://www.abusar.org/htb/dump-mail-server.log
http://www.abusar.org/htb/dump-mail-client.log

	Both readmibs:

http://www.abusar.org/htb/readmibs-server.txt
http://www.abusar.org/htb/readmibs-client.txt

	Here are both cat /proc/net/tcp:

http://www.abusar.org/htb/tcp-server.txt
http://www.abusar.org/htb/tcp-client.txt

	I use the following to generate those dumps:

	1) on the server:

tcpdump -s 0 -w dump-mail-server.log -i eth0 host 201.52.214.230

	2) on the client:

tcpdump -s 0 -w dump-mail-client.log -i eth0 host teleporto.abusar.org =
and port 995

	What happened?

1) the connection was stalled

2) these tcpdumps are the *best ones* I got because although I started =
them with
the connection already stalled, the connection suddenly is not stalled =
anymore,
and a few minutes later was stalled again...

3) I keep tcpdump running for more time
=09
	Ps: anyway I could notice that the only two services that
remain stalled is nntp, ftp, pop3 and smtp... http is never stalled,
neither ssh. It seems to affect only "old" protocols :)

	Ps2: anyway, the htb patch seems to help, because the problem
took much longer to happen. With htb patches the problem happens one ti=
me a day.=20
Without the htb patches the problem happens more than one time a day.

	Ps3: I really doesn't understand why "nmap -sS server"
"solves" the stalled connection issue.

	Ps4: sorry for my hurry feedback before. I thought the problem had gon=
e. Anyway,=20
I hope this time I provided the best data for you. Thanks.

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
