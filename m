From: Tim Gardner <timg@tpi.com>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 10:39:21 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095784761.3934.52.camel@tim.rtg.net>
References: <20040922.001448.73843048.yoshfuji@linux-ipv6.org>
	 <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi>
	 <20040922.010428.104988024.yoshfuji@linux-ipv6.org>
Reply-To: timg@tpi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: pekkas@netcore.fi, laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1?= =?UTF-8?Q?=E6=98=8E?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040922.010428.104988024.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 10:04, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E wrote:
> In article <Pine.LNX.4.44.0409211856260.9906-100000@netcore.fi> (at Tue=
, 21 Sep 2004 18:58:05 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> sa=
ys:
>=20
> > This still doesn't take a stance on rate-limiting the ND/ARP packets,
> > in case that there still is enough memory, but some kind of attack is
> > clearly underway.  Should it still be done?  Consider 100Kpps of
> > router-generated ARP/ND probes -- not good!
>=20

Detecting an attack would require some kind of heuristic in the core
router code. I believe that logic is better suited for an iptables
filter. Why burden well guarded machines that are unikely to experience
this kind of attack? I think the only thing NUD should do is limit the
absolute number of NUD entries that it can create. Give it a sysctl knob
for large networks, but make the default something reasonable (like
2K). =20

I've developed a variant of the Port Scan Detector (PSD) iptables filter
that combats this very problem. It only allows so many destination
IP/Port pairs from a given address to be opened over time. This limits
the rate at which connections can be opened as well as the absolute
number. For example, on my edge routers I set the policy that no single
IP source address can create more then 64 connections within a 30 second
sliding window. This has made a huge impact on the ARP storms that our
network used to experience.

rtg

--=20
timg@tpi.com http://www.tpi.com
406-443-5357(MT) 503-601-0234(OR)
