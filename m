From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc8 regression with openswan
Date: Tue, 08 Apr 2008 21:08:31 +0200
Message-ID: <47FBC2AF.7050508@trash.net>
References: <BAY103-DAV8D067EC595CECC2C4281CB2F70@phx.gbl> <47F4BD3F.30703@trash.net> <BAY103-DAV6A19A7FE52B2CD3AD1B0EB2F70@phx.gbl> <47F4C833.1020607@trash.net> <BAY103-DAV8C5CABF10D4685C448331B2F70@phx.gbl> <47F4CF29.2000104@trash.net> <47F4E12B.3040508@trash.net> <BAY103-DAV125214C1E537F51083DAB6B2F70@phx.gbl> <47F4EB73.1040705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kazunori MIYAZAWA <kazunori@miyazawa.org>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49383 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbYDHTLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 15:11:21 -0400
In-Reply-To: <47F4EB73.1040705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> The problem appears to be that openswan doesn't initialize the
> selectors family when adding new SAs. xfrm_init_state() uses
> the family to decide whether to set up inter family SAs or
> regular SAs. We used to fix up the family in xfrm_user, but
> this is now only done for transport mode SAs.
>
> -       /*
> -        * Set inner address family if the KM left it as zero.
> -        * See comment in validate_tmpl.
> -        */
> -       if (!x->sel.family)
> +       if (x->props.mode == XFRM_MODE_TRANSPORT)
>                 x->sel.family = p->family;
> +
>
> Reverting this part should fix it, but would break inter family
> tunnels again. It seems we need a different indication for
> xfrm_init_state() for inter family SAs.
>
> Kazunori, any ideas?


Did you have a chance to look into this? This is most likely
going to break a lot of setups, so a fix is really needed
before 2.6.25 is released.


