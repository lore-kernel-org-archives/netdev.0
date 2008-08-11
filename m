From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Mon, 11 Aug 2008 14:44:21 -0700 (PDT)
Message-ID: <20080811.144421.234396007.davem@davemloft.net>
References: <Pine.LNX.4.64.0808071422360.4551@wrl-59.cs.helsinki.fi>
	<20080808004231.10dd7356.billfink@mindspring.com>
	<Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: billfink@mindspring.com, fragabr@gmail.com,
	thomas.jarosch@intra2net.com, netdev@vger.kernel.org,
	kaber@trash.net, sr@securenet.de, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu
To: ilpo.jarvinen@helsinki.fi
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 8 Aug 2008 13:32:14 +0300 (EEST)

> On Fri, 8 Aug 2008, Bill Fink wrote:
> > A question then arises is if the bogus scenario has a TCP signature
> > that could be used to print a warning message for the unsuspecting
> > user so they could then take necessary corrective action.
>=20
> Probably yes, but I need to add some state. I could probably also mak=
e it=20
> to switch per flow to more robust approach on-demand when enough evid=
ence=20
> is gathered. ...I think I'll add 1-bit history counter per flow so th=
at=20
> it's possible to do print the warning and switch when there's third R=
TO in=20
> a single window (while two first were found spurious). IMHO it's unli=
kely=20
> enough that there will be three latency spikes (each longer than the=20
> previous) within a single window to make the decision, I wouldn't tru=
st=20
> two enough because hand-overs can take time and have non-trivial effe=
cts.

Trying to come up with a signature for this bogus stuff is both time
consuming and having a risk of false positives.  And I really question
whether this thing is worth it.

The sane thing to do in this case is to declare the box inoperative
and that it needs to be fixed to avoid this behavior.

Any reasonable congestion control scheme is going to run into problems
trying to react to the packet patterns this thing creates.  It is
therefore not really limited to FRTO so it really shouldn't be treated
like an FRTO problem even though it shows up more pronounced when
=46RTO is enabled.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
