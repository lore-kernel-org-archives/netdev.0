From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] usb: gadget: nokia: disallow compilation with HIGHMEM
Date: Tue, 8 Feb 2011 09:39:11 +0200
Message-ID: <201102080939.12122.remi.denis-courmont@nokia.com>
References: <1297150245-31696-1-git-send-email-ext-eero.nurkkala@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, dbrownell@users.sourceforge.net,
	netdev@vger.kernel.org
To: ext-eero.nurkkala@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:40901 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876Ab1BHHjG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 02:39:06 -0500
In-Reply-To: <1297150245-31696-1-git-send-email-ext-eero.nurkkala@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 08 February 2011 09:30:45 ext-eero.nurkkala@nokia.com, you w=
rote:
> From: Eero Nurkkala <ext-eero.nurkkala@nokia.com>
>=20
> With HIGHMEM, g_phonet oopses with the following path:
> pn_rx_complete() -> pskb_pull() -> ... kmap_skb_frag() and
> oops with BUG_ON(in_irq()). Thus, if the gadget is enabled,
> it'd better conflict with the HIGHMEM.
>=20
> Signed-off-by: Eero Nurkkala <ext-eero.nurkkala@nokia.com>

Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>


In the long run, we should probably kludge the skb code like we did in
cdc-phonet.c.

Or better yet, fix kmap_skb_frag() to be less pessimistic. Thing is, th=
e BUG_ON=20
is really bogus here. The way we allocated the skb, the fragment really=
 cannot=20
be in HIGHMEM...

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
