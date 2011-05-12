From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Thu, 12 May 2011 13:59:59 +0200
Message-ID: <20110512115959.GA37368@tuxmaker.boeblingen.de.ibm.com>
References: <20110512054318.241733700@de.ibm.com> <20110512054415.435611676@de.ibm.com> <BANLkTinO4Hity5++152Ff-RuACFDtoAV2Q@mail.gmail.com> <20110512072132.GA31817@tuxmaker.boeblingen.de.ibm.com> <BANLkTimAisv82ZbFb8D1AkL8vuK1V5zAXw@mail.gmail.com> <20110512111009.GA4176@tuxmaker.boeblingen.de.ibm.com> <BANLkTimUq-6E1F_ns_jTvXuYoPU-sLUmqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:34397 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756275Ab1ELMAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 08:00:02 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTimUq-6E1F_ns_jTvXuYoPU-sLUmqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2011 at 01:25:51PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
> W dniu 12 maja 2011 13:10 u=C5=BCytkownik Frank Blaschka
> <blaschka@linux.vnet.ibm.com> napisa=C5=82:
> > On Thu, May 12, 2011 at 10:12:51AM +0200, Micha=C5=82 Miros=C5=82aw=
 wrote:
> >> W dniu 12 maja 2011 09:21 u=C5=BCytkownik Frank Blaschka
> >> <blaschka@linux.vnet.ibm.com> napisa=C5=82:
> >> > On Thu, May 12, 2011 at 07:59:45AM +0200, Micha=C5=82 Miros=C5=82=
aw wrote:
> >> >> 2011/5/12 =C2=A0<frank.blaschka@de.ibm.com>:
> >> >> > Set rx csum default to hw checksumming again.
> >> >> > Remove sysfs interface for rx csum (checksumming) and TSO (la=
rge_send).
> >> >> > With the new hw_features it does not work to keep the old sys=
fs
> >> >> > interface in parallel. Convert options.checksum_type to new h=
w_features.
> >> >> [...]
> >> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* hw may =
have changed during offline or recovery */
> >> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!qeth_=
is_supported(card, IPA_INBOUND_CHECKSUM)) {
> >> >> [...]
> >> >>
> >> >> This check should go to ndo_fix_features callback. If it fails =
then
> >> >> just return features &~NETIF_F_RXCSUM from there ...
> >> >>
> > Ok so all I have to do to complete this is to remove
> > =C2=A0card->dev->hw_features &=3D ~NETIF_F_RXCSUM;
> > from here (ndo_fix_feature has already the check)?
> >
> > Since we might be in recovery it is smarter to keep the support che=
ck here so we
> > do not have to use try and error approach to see if capabilities ha=
ve
> > changed. Do you aggree?
>=20
> The key is that the driver should call netdev_update_features()
> whenever some conditions affecting available features might have
> changed. If you can keep the checks contained inside ndo_fix_features
> callback, you can avoid caring about the offloads in the recovery
> process.
Ok, we have this now.
>=20
> There's also the question what happens when packets are queued while
> there's ongoing recovery? Simplest way would be to drop them all unti=
l
> recovery completes.
Since this is RX processing there is nothing queued during recovery. Bu=
t
you are right for tx csum or TSO we have to think about this. For now
I would like to complete this patch.
>=20
> Best Regards,
> Micha=C5=82 Miros=C5=82aw
> --
> To unsubscribe from this list: send the line "unsubscribe linux-s390"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
