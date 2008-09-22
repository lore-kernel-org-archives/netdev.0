From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Mon, 22 Sep 2008 01:23:38 -0300
Message-ID: <20080922012338.694d30b0@tux>
References: <20080819213417.45133573@tux>
	<20080824163843.33b4f890@tux>
	<Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi>
	<20080826141812.589848a0@tux>
	<Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi>
	<20080828184919.611dd578@tux>
	<Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
	<20080830035650.42be37d7@tux>
	<Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
	<20080907051718.58bf133d@tux>
	<Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
	<20080908172043.0d25a427@tux>
	<Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
	<20080911143006.2f516569@tux>
	<Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi>
	<20080913203117.2a55ea2c@tux>
	<Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi>
	<20080916112411.062fa615@tux>
	<Pine.LNX.4.64.0809161726250.1034@wrl-59.cs.helsinki.fi>
	<20080918173554.1f874238@tux>
	<Pine.LNX.4.64.0809182349410.4742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0809182349410.4742@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 19 Sep 2008 00:04:23 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Anyway, if/when you succeed collecting some strace of the server=20
> processes, please let me know (though putting a full one available mi=
ght=20
> not be wise thing like I said earlier). After I thought it a bit, it =
might=20
> be enough the start the strace with -p for all server processes of a=20
> service during a stall and then resolve it after some amount of waiti=
ng=20
> with nmap (and hope that strace doesn't resolve it by interfering=20
> something relevant :-), you will see that from the fact that it resol=
ves=20
> without nmap then). That would probably reveal if the processes where=
=20
> waiting in accept() or not, and if not, where they were.

	Hi again Ilpo, I waited the whole day for a stall, and
fortunatelly it happened while I was stracing dovecot and child
processes. The stall happened at 01:11 (at the end). I hope that it
has something useful.

http://www.abusar.org/strace/dovecot.txt.bz2

	I then nmap'ed the server and killed strace.

	I used the following:

strace -t -p 2315 -f -e trace=3Daccept,listen,close,shutdown,select -o =
dovecot.txt

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
