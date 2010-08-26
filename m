From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: RFC: MTU for serving NFS on Infiniband
Date: Thu, 26 Aug 2010 16:53:59 -0700
Message-ID: <20100826165359.3b79b27d@nehalam>
References: <alpine.LNX.2.00.1008230842290.9325@abcyxhiz.aict.ualberta.ca>
	<20100823080543.319143e3@nehalam>
	<alpine.WNT.2.00.1008240856170.2000@cluij.ucs.ualberta.ca>
	<1282672647.2302.15.camel@achroite.uk.solarflarecom.com>
	<alpine.WNT.2.00.1008241338470.1132@cluij.ucs.ualberta.ca>
	<1282688441.22839.34.camel@localhost>
	<20100824153920.63360072@s6510>
	<alpine.WNT.2.00.1008251408520.632@cluij.ucs.ualberta.ca>
	<1282823827.2476.663.camel@edumazet-laptop>
	<alpine.WNT.2.00.1008260835020.2008@cluij.ucs.ualberta.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Marc Aurele La France <tsi@ualberta.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.WNT.2.00.1008260835020.2008@cluij.ucs.ualberta.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2010 08:43:42 -0600 (Mountain Daylight Time)
Marc Aurele La France <tsi@ualberta.ca> wrote:

> On Thu, 26 Aug 2010, Eric Dumazet wrote:
> > Le jeudi 26 ao=FBt 2010 =E0 05:40 -0600, Marc Aurele La France a =E9=
crit :
>=20
> >> Steady now.  There's no need to YELL nor be arrogant.  You and I b=
oth know
> >> there's a place for NFS over UDP.  That's not changing any time so=
on.  While
> >> I'm aware of the issue you brought up, it is separate from the one=
 at hand in
> >> this discussion.
>=20
> >> I do want to thank you, however, for reminding me of TCP.  It's so=
mething
> >> 20/20 hindsight says I should have checked out before starting thi=
s thread.
> >> Logistically, it'll be a few days before I can do so though.  If t=
hat allows
> >> me to increase the MTU all the way up to 65520, then this UDP thin=
g will
> >> likely remain unresolved.
>=20
> > Unfortunately, your infiniband device lacks NETIF_F_SG support.
>=20
> Oh, the device itself probably has something similar, but ipoib=20
> (IP-over-Infiniband) doesn't export that capability.
>=20
> > MTU a bit larger than PAGE_SIZE-overhead will need high order
> > allocations ?
>=20
> Right.  And a 65520 MTU allocates sk_buff's with 128K contiguous payl=
oads.

Infiniband device driver needs to be fixed to do SG and checksum offloa=
d.
Otherwise it is insane to try and run large MTU over it. I even wonder =
if
the dev_change_mtu() function should reject > PAGESIZE mtu for devices
that don't do scatter/gather or at least a raise a warning.
