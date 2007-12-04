From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Tue, 04 Dec 2007 16:17:29 -0500
Message-ID: <4755C3E9.4090609@psc.edu>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi> <47559FA1.2090104@psc.edu> <Pine.LNX.4.64.0712042252450.12072@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Matt Mathis <mathis@psc.edu>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:56420 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757047AbXLDVRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 16:17:38 -0500
In-Reply-To: <Pine.LNX.4.64.0712042252450.12072@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Tue, 4 Dec 2007, John Heffner wrote:
>=20
>> Ilpo J=E4rvinen wrote:
>>> ...I'm still to figure out why tcp_cwnd_down uses snd_ssthresh/2
>>> as lower bound even though the ssthresh was already halved, so snd_=
ssthresh
>>> should suffice.
>> I remember this coming up at least once before, so it's probably wor=
th a
>> comment in the code.  Rate-halving attempts to actually reduce cwnd =
to half
>> the delivered window.  Here, cwnd/4 (ssthresh/2) is a lower bound on=
 how far
>> rate-halving can reduce cwnd.  See the "Bounding Parameters" section=
 of
>> <http://www.psc.edu/networking/papers/FACKnotes/current/>.
>=20
> Thanks for the info! Sadly enough it makes NewReno recovery quite=20
> inefficient when there are enough losses and high BDP link (in my cas=
e=20
> 384k/200ms, BDP sized buffer). There might be yet another bug in it a=
s=20
> well (it is still a bit unclear how tcp variables behaved during my=20
> scenario and I'll investigate further) but reduction in the transfer=20
> rate is going to last longer than a short moment (which is used as=20
> motivation in those FACK notes). In fact, if I just use RFC2581 like=20
> setting w/o rate-halving (and experience the initial "pause" in sendi=
ng),=20
> the ACK clock to send out new data works very nicely beating rate hal=
ving=20
> fair and square. For SACK/FACK it works much nicer because recovery i=
s=20
> finished much earlier and slow start recovers cwnd quickly.

I believe this is exactly the reason why Matt (CC'd) and Jamshid=20
abandoned this line of work in the late 90's.  In my opinion, it's=20
probably not such a bad idea to use cwnd/2 as the bound.  In some=20
situations, the current rate-halving code will work better, but as you=20
point out, in others the cwnd is lowered too much.


> ...Mind if I ask another similar one, any idea why prior_ssthresh is=20
> smaller (3/4 of it) than cwnd used to be (see tcp_current_ssthresh)?

Not sure on that one.  I'm not aware of any publications this is based=20
on.  Maybe Alexey knows?

   -John
