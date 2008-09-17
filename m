From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Wed, 17 Sep 2008 13:23:28 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809161726250.1034@wrl-59.cs.helsinki.fi>
References: <20080819213417.45133573@tux> <20080822183224.2d52f16c@tux>
 <20080822.143709.65615512.davem@davemloft.net> <20080823111446.06a350a2@tux>
 <Pine.LNX.4.64.0808231736490.10712@wrl-59.cs.helsinki.fi> <20080824163843.33b4f890@tux>
 <Pine.LNX.4.64.0808250948420.27330@wrl-59.cs.helsinki.fi> <20080826141812.589848a0@tux>
 <Pine.LNX.4.64.0808262034001.1168@wrl-59.cs.helsinki.fi> <20080828184919.611dd578@tux>
 <Pine.LNX.4.64.0808291045430.7971@wrl-59.cs.helsinki.fi> <20080830035650.42be37d7@tux>
 <Pine.LNX.4.64.0808301000180.12388@wrl-59.cs.helsinki.fi> <20080907051718.58bf133d@tux>
 <Pine.LNX.4.64.0809071341310.8991@wrl-59.cs.helsinki.fi> <20080908172043.0d25a427@tux>
 <Pine.LNX.4.64.0809100942370.24708@wrl-59.cs.helsinki.fi> <20080911143006.2f516569@tux>
 <Pine.LNX.4.64.0809112140250.26799@wrl-59.cs.helsinki.fi> <20080913203117.2a55ea2c@tux>
 <Pine.LNX.4.64.0809140722460.17271@wrl-59.cs.helsinki.fi> <20080916112411.062fa615@tux>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1880103045-1221575897=:1034"
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "=?ISO-8859-1?Q?D=E2niel?= Fraga" <fragabr@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080916112411.062fa615@tux>
Content-ID: <Pine.LNX.4.64.0809171309380.1034@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1880103045-1221575897=:1034
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0809171309381.1034@wrl-59.cs.helsinki.fi>

On Tue, 16 Sep 2008, Dâniel Fraga wrote:

> On Tue, 16 Sep 2008 15:10:33 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > Only thing I know to ask is, do you have any idea if your ntpd is 
> > hard-stepping the time instead of adjusting the clock's rate a bit (the 
> > latter should keep the clock monotonious besides potential bugs)?
> 
> 	I assume it's adjusting the clock's rate a bit. Anyway, it's a
> pretty simple config:
> 
> fraga@teleporto ~$ cat /etc/ntp.conf 
> server ntp.usp.br
> server ntp.nasa.gov
> driftfile /etc/ntp.drift
> 
> 	And ntpd is running without any special parameters.
> 
> 	The log messages are as simple as:
> 
> Sep 15 03:56:04 teleporto ntpd[2301]: frequency initialized 5.891 PPM from /etc/ntp.drift
> Sep 15 03:59:25 teleporto ntpd[2304]: frequency initialized 5.891 PPM from /etc/ntp.drift
> Sep 15 04:03:49 teleporto ntpd[2304]: synchronized to 143.107.255.15, stratum 2
> Sep 15 04:03:49 teleporto ntpd[2304]: kernel time sync status change 0001
> Sep 15 04:10:16 teleporto ntpd[2304]: synchronized to 198.123.30.132, stratum 1
> Sep 15 04:11:58 teleporto ntpd[2301]: frequency initialized 5.891 PPM from /etc/ntp.drift
> Sep 15 04:16:18 teleporto ntpd[2301]: synchronized to 198.123.30.132, stratum 1
> Sep 15 04:16:18 teleporto ntpd[2301]: kernel time sync status change 0001
> Sep 15 12:08:53 teleporto ntpd[2301]: kernel time sync status change 4001
> Sep 15 12:34:31 teleporto ntpd[2301]: kernel time sync status change 0001
> Sep 15 14:34:06 teleporto ntpd[2301]: kernel time sync status change 4001
> Sep 15 14:51:12 teleporto ntpd[2301]: kernel time sync status change 0001 

I was to look where these (or actually the ones you mentioned earlier) 
messages exactly originate from in the source of ntpd but didn't yet have 
time.

> 	If I understood correctly what do you mean, ntpd adjusts nicely the time to not 
> cause huge differences in the time.

It is definately the default, if it's even possible to configure ntpd to 
just set forcibly the new time (with ntpdate you can decide that with 
-b/-B switch iirc).

> 	And we're reaching the conclusion that the timer code from 2.6.25 
> and above have something wrong, since 2.6.24 and below is ok, which 
> causes those stalls.

There were some other timer related complications in 2.6.25 but it's so 
long time ago that I hardly remember anything about those anymore (and 
I'm not an expert on those things anyway). And it's still very open issue 
how that would cause the problem you're seeing.

> 	And just a question: do you use ntpd on your own desktop?

Yes.


-- 
 i.
---696208474-1880103045-1221575897=:1034--
