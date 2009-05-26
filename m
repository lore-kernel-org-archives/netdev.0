From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Tue, 26 May 2009 12:40:16 -0700
Message-ID: <200905261240.17182.david-b@pacbell.net>
References: <1243333007-25645-1-git-send-email-vapier@gentoo.org> <200905260424.17654.david-b@pacbell.net> <8A42379416420646B9BFAC9682273B6D0B2B671E@limkexm3.ad.analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Baruch Siach" <baruch@tkos.co.il>,
	"Mike Frysinger" <vapier@gentoo.org>, netdev@vger.kernel.org,
	"Bryan Wu" <cooloney@kernel.org>
To: "Hennerich, Michael" <Michael.Hennerich@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n25.bullet.mail.mud.yahoo.com ([68.142.206.220]:36262 "HELO
	n25.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755891AbZEZTkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 15:40:17 -0400
In-Reply-To: <8A42379416420646B9BFAC9682273B6D0B2B671E@limkexm3.ad.analog.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 May 2009, Hennerich, Michael wrote:
> The comment block above request_irq states:
>=20
> >> > =A0=A0=A0 * level triggers won't currently work.
>=20
> And I guess it's because IRQ handling is deferred to a work queue.

The IRQ needs to no longer be pending when the (hard) handler returns.
=46or level triggers, that means disabling the IRQ ... then re-enabling
it only when the (soft/threaded) handler returns.


> I wonder how IRQF_TRIGGER_FALLING | IRQF_TRIGGER_RISING will work in
> such a case.

It works just fine, since when the (hard) handler returns there is
no longer "IRQ pending" status in the IRQ controller.


> Since the ENC28J60 /INT will de-assert during the work handler execut=
es,
> thus causing a second spurious interrupt.

No problem.  The Ethernet adapter has no pending (unless another IRQ
triggered meanwhile); its workqueue/threaded handler returns immediatel=
y.



