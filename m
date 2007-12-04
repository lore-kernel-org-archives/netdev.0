From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH net-2.6 0/3]: Three TCP fixes
Date: Tue, 04 Dec 2007 13:42:41 -0500
Message-ID: <47559FA1.2090104@psc.edu>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:51858 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755114AbXLDSw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 13:52:28 -0500
In-Reply-To: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> ...I'm still to figure out why tcp_cwnd_down uses snd_ssthresh/2
> as lower bound even though the ssthresh was already halved,=20
> so snd_ssthresh should suffice.

I remember this coming up at least once before, so it's probably worth =
a=20
comment in the code.  Rate-halving attempts to actually reduce cwnd to=20
half the delivered window.  Here, cwnd/4 (ssthresh/2) is a lower bound=20
on how far rate-halving can reduce cwnd.  See the "Bounding Parameters"=
=20
section of <http://www.psc.edu/networking/papers/FACKnotes/current/>.

   -John
