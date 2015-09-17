From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 2/2]  8139cp: reset BQL when ring tx ring cleared
Date: Thu, 17 Sep 2015 22:44:49 +0200
Message-ID: <20150917204449.GA22105@electric-eye.fr.zoreil.com>
References: <20130520095443.2d18b2cb@nehalam.linuxnetplumber.net>
 <20130520213728.GA28252@electric-eye.fr.zoreil.com>
 <20130520172749.2a4447b6@nehalam.linuxnetplumber.net>
 <1442232308.30875.6.camel@infradead.org>
 <20150914215913.GA24962@electric-eye.fr.zoreil.com>
 <1442489793.131189.142.camel@infradead.org>
 <1442502391.131189.160.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59916 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbbIQUpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 16:45:47 -0400
Content-Disposition: inline
In-Reply-To: <1442502391.131189.160.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
> On Thu, 2015-09-17 at 12:36 +0100, David Woodhouse wrote:
> >=20
> > Thanks; I'll try that. In fact since updating to 4.2 the problem ha=
s
> > got worse =E2=80=94 now the whole machine dies:
>=20
> There is something very strange going on here. I've found two ways to
> make it stop crashing when cp_tx_timeout() hits the 'popf' when
> unlocking the spinlock.

cp_tx_timeout takes lock, disables irq, calls cp_clean_rings, thus
plain dev_kfree_skb if a skb is still referenced in one of the
rx/tx ring. You may replace it with dev_kfree_skb_any.

--=20
Ueimor
