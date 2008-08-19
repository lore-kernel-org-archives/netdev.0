From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Tue, 19 Aug 2008 08:56:07 +0800
Message-ID: <1219107367.8781.3.camel@ymzhang>
References: <48A086B6.2000901@linux-foundation.org>
	 <20080811.141501.01468546.davem@davemloft.net>
	 <Pine.LNX.4.64.0808121058550.4551@wrl-59.cs.helsinki.fi>
	 <1219025114.25933.6.camel@ymzhang>
	 <Pine.LNX.4.64.0808181044470.23854@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, cl@linux-foundation.org,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:28655 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754959AbYHSA5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 20:57:21 -0400
In-Reply-To: <Pine.LNX.4.64.0808181044470.23854@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-08-18 at 10:53 +0300, Ilpo J=E4rvinen wrote:
> On Mon, 18 Aug 2008, Zhang, Yanmin wrote:
>=20
> >=20
> > On Tue, 2008-08-12 at 11:13 +0300, Ilpo J=E4rvinen wrote:=20
> > > On Mon, 11 Aug 2008, David Miller wrote:
> > >=20
> > > > From: Christoph Lameter <cl@linux-foundation.org>
> > > > Date: Mon, 11 Aug 2008 13:36:38 -0500
> > > >=20
> > > > > It seems that the network stack becomes slower over time? Her=
e is a list of
> > > > > tbench results with various kernel versions:
> > > > >=20
> > > > > 2.6.22		3207.77 mb/sec
> > > > > 2.6.24		3185.66
> > > > > 2.6.25		2848.83
> > > > > 2.6.26		2706.09
> > > > > 2.6.27(rc2)	2571.03
> > > > >=20
> > > > > And linux-next is:
> > > > >=20
> > > > > 2.6.28(l-next)	2568.74
> > > > >=20
> > > > > It shows that there is still have work to be done on linux-ne=
xt. Too close to
> > > > > upstream in performance.
> > > > >=20
> > > > > Note the KT event between 2.6.24 and 2.6.25. Why is that?
> > > >=20
> > > > Isn't that when some major scheduler changes went in?  I'm not =
blaming
> > > > the scheduler, but rather I'm making the point that there are o=
ther
> > > > subsystems in the kernel that the networking interacts with tha=
t
> > > > influences performance at such a low level.
> > >=20
> > > ...IIRC, somebody in the past did even bisect his (probably netpe=
rf)=20
> > > 2.6.24-25 regression to some scheduler change (obviously it might=
 or might=20
> > > not be related to this case of yours)...
> > I did find much regression with netperf TCP-RR-1/UDP-RR-1/UDP-RR-51=
2. I start
> > 1 serve and 1 client while binding them to a different logical proc=
essor in
> > different physical cpu.
> >=20
> > Comparing with 2.6.22, the regression of TCP-RR-1 on 16-core tigert=
on is:
> > 2.6.23		6%
> > 2.6.24		6%
> > 2.6.25		9.7%
> > 2.6.26		14.5%
> > 2.6.27-rc1	22%
> >=20
> > Other regressions on other machines are similar.
>=20
> I btw reorganized tcp_sock for 2.6.26, it shouldn't cause this but it=
's=20
> not always obvious what even a small change in field ordering does fo=
r=20
> performance (it's b79eeeb9e48457579cb742cd02e162fcd673c4a3 in case yo=
u=20
> want to check that).
>=20
> Also, there was this 83f36f3f35f4f83fa346bfff58a5deabc78370e5 fix to=20
> current -rcs but I guess it might not be that significant in your cas=
e=20
> (but I don't know well enough :-)).
I reverted the patch against 2.6.27-rc1 and did a quick testing with ne=
tperf TCP-RR-1
and didn't find improvement. So your patch is good.
Mostly, I suspect process scheduler causes the regression. It seems whe=
n there are=20
only 1 or 2 tasks running on the cpu, the performance isn't good. My ne=
tperf testing
is just one example.


