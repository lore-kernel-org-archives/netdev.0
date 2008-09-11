From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Thu, 11 Sep 2008 15:12:22 -0300
Message-ID: <20080911151222.0ce12158@tux>
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
	<20080828184919.611dd578@tux>
	<Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi>
	<20080830035650.42be37d7@tux>
	<Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi>
	<20080907051718.58bf133d@tux>
	<Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi>
	<20080908172043.0d25a427@tux>
	<Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Sep 2008 16:44:20 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> ...I guess it would be possible to remove SCHED_FEAT_HRTICK from
> /proc/sys/kernel/sched_features then while keeping the hrtimers
> otherwise enabled to test this.
>=20
> It's possible that hrtimers just affect on how easy it is to trigger
> but at least it seems an useful lead until proven otherwise.

	Well, I have a new suspect now: ntpd. It seems that when ntpd
syncs the clock, the problem happens (just a guess):

Sep 11 13:55:31 tux ntpd[2652]: synchronized to 143.107.255.15, stratum=
 2=20
Sep 11 13:55:31 tux ntpd[2652]: kernel time sync enabled 0001

	I disabled ntpd (and I'll just sync the clock with ntpdate just one=20
time at the boot) and see what happens. I think the problem could be re=
lated
to this, since "sudo" is affected too and as far as I know, sudo is ver=
y=20
sensible to timer.


--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
