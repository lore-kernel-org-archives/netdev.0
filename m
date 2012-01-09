From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] gianfar: Fix invalid TX frames returned on error queue
 when time stamping.
Date: Mon, 9 Jan 2012 13:41:08 +0100
Message-ID: <20120109124108.GA4404@cherladcori01>
References: <1325775021-23049-1-git-send-email-manfred.rudigier@omicron.at>
 <20120105.132637.2130515220408371607.davem@davemloft.net>
 <95DC1AA8EC908B48939B72CF375AA5E3013A99124D@alice.at.omicron.at>
 <1326095038.2627.4.camel@edumazet-laptop>
 <95DC1AA8EC908B48939B72CF375AA5E3013A99137D@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"afleming@freescale.com" <afleming@freescale.com>,
	"avorontsov@mvista.com" <avorontsov@mvista.com>
To: Manfred Rudigier <manfred.rudigier@omicron.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:55659 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188Ab2AIMlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 07:41:21 -0500
Received: by wibhm6 with SMTP id hm6so2509033wib.19
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2012 04:41:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <95DC1AA8EC908B48939B72CF375AA5E3013A99137D@alice.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2012 at 10:36:44AM +0100, Manfred Rudigier wrote:
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> Sent: Monday, January 09, 2012 08:44
>=20
> >Le lundi 09 janvier 2012 =C3=A0 08:16 +0100, Manfred Rudigier a =C3=A9=
crit :
> >> From: David Miller [mailto:davem@davemloft.net]
> >> Sent: Thursday, January 05, 2012 19:27
> >>
> >> >From: Manfred Rudigier <manfred.rudigier@omicron.at>
> >> >Date: Thu, 5 Jan 2012 15:50:21 +0100
> >> >
> >> >> +
> >> >> +		/* Keep sock if we must return a time stamp on the err queue=
 */
> >> >> +		skb_new->sk =3D skb->sk;
> >> >
> >> >When I see something like this without any kind of reference coun=
ting
> >> >or similar, I am gravely concerned.
> >>
> >> The skb_tstamp_tx function called during gfar_clean_tx_ring requir=
es
> >> the skb->sk pointer to be set. Otherwise no time stamp can be queu=
ed
> >> on the socket error queue.
> >> What would be the correct way for doing this?
> >
> >I really wonder how your code was possibly working...
>=20
> Well, it was working :-)

It was only working because the conditional was always false:

	if (((skb->ip_summed =3D=3D CHECKSUM_PARTIAL) ||
      	   		vlan_tx_tag_present(skb) ||
			unlikely(do_tstamp)) &&
			(skb_headroom(skb) < GMAC_FCB_LEN)) {
		struct sk_buff *skb_new;
		...
	}

IOW, there was always at least GMAC_FCB_LEN bytes in skb_headroom.

Richard
