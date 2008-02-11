From: David Brownell <david-b@pacbell.net>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix, low power mode
Date: Mon, 11 Feb 2008 12:23:49 -0800
Message-ID: <200802111223.49823.david-b@pacbell.net>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200802100954.18225.david-b@pacbell.net> <47B03A9A.2060605@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp121.sbc.mail.sp1.yahoo.com ([69.147.64.94]:47653 "HELO
	smtp121.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753645AbYBKUXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 15:23:52 -0500
In-Reply-To: <47B03A9A.2060605@eptar.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 February 2008, Claudio Lanconelli wrote:
> I have tried your latest patch. Only after the following change it
> works fine (no more rx errors during ifconfig up).

Hmm, what chip rev do you have?  Different errata and all.
ISTR mine is rev4; so, not the most current, but not the
oldest version either.


> I added enc28j60_lowpower(false) just before enc28j60_hw_init()

Hmm, I'd have expected it would go best *before* that, but
what you include below shows it going *after* ...

If there's some problem where reset doesn't work correctly
in low power mode, who knows what else would need manual
resetting.

=20
> @@ -1318,8 +1347,9 @@
> =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0return -EADDRNOTAVAIL;
> =A0 =A0 =A0}
> - =A0 =A0/* Reset the hardware here */
> + =A0 =A0/* Reset the hardware here (and take it out of low power mod=
e) */
> =A0 =A0 =A0enc28j60_hw_disable(priv);
> + =A0 =A0enc28j60_lowpower(priv, false);
> =A0 =A0 =A0if (!enc28j60_hw_init(priv)) {
> =A0 =A0 =A0 =A0 =A0if (netif_msg_ifup(priv))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&dev->dev, "hw_reset() failed\n");
>
> With this addition you can add Acked-by line.

Better yet, since I can't reproduce the problem, why don't
you just update my latest patch with the relevant version
of this tweak, and then forward it as "From: " me and with
both our signoffs.  That's the usual way to cope with this
type of tweaking.  (Not all updates to your driver should
need your signoff, but then most patches shouldn't need
very many iterations either.)

- Dave


