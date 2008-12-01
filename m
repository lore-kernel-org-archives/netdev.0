From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH net-next] Phonet: basic net namespace support
Date: Mon, 1 Dec 2008 14:36:24 +0200
Message-ID: <200812011436.25064.remi.denis-courmont@nokia.com>
References: <> <1228132957-18373-1-git-send-email-remi.denis-courmont@nokia.com> <1228133869.10480.10.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Denis V. Lunev" <den@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:25698 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbYLAMhY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 07:37:24 -0500
In-Reply-To: <1228133869.10480.10.camel@iris.sw.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 01 December 2008 14:17:49 ext Denis V. Lunev, you wrote:
> On Mon, 2008-12-01 at 14:02 +0200, R=E9mi Denis-Courmont wrote:
> [snip]
>
> > -int phonet_address_lookup(u8 addr)
> > +int phonet_address_lookup(struct net *net, u8 addr)
> >  {
> >  	struct phonet_device *pnd;
> >
> >  	spin_lock_bh(&pndevs.lock);
> >  	list_for_each_entry(pnd, &pndevs.list, list) {
> > +		if (dev_net(pnd->netdev) !=3D net)
> > +			continue;
>
> net_eq is better (noop without netns). also there are some similar
> places below

Ah ok, thanks for pointing it out. Here comes the two rewritten patches=
=2E..

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
