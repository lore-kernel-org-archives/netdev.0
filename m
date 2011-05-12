From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch 1/9] [PATCH] qeth: convert to hw_features part 2
Date: Thu, 12 May 2011 13:25:51 +0200
Message-ID: <BANLkTimUq-6E1F_ns_jTvXuYoPU-sLUmqw@mail.gmail.com>
References: <20110512054318.241733700@de.ibm.com> <20110512054415.435611676@de.ibm.com>
 <BANLkTinO4Hity5++152Ff-RuACFDtoAV2Q@mail.gmail.com> <20110512072132.GA31817@tuxmaker.boeblingen.de.ibm.com>
 <BANLkTimAisv82ZbFb8D1AkL8vuK1V5zAXw@mail.gmail.com> <20110512111009.GA4176@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:62643 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214Ab1ELL0M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 07:26:12 -0400
In-Reply-To: <20110512111009.GA4176@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 12 maja 2011 13:10 u=BFytkownik Frank Blaschka
<blaschka@linux.vnet.ibm.com> napisa=B3:
> On Thu, May 12, 2011 at 10:12:51AM +0200, Micha=B3 Miros=B3aw wrote:
>> W dniu 12 maja 2011 09:21 u=BFytkownik Frank Blaschka
>> <blaschka@linux.vnet.ibm.com> napisa=B3:
>> > On Thu, May 12, 2011 at 07:59:45AM +0200, Micha=B3 Miros=B3aw wrot=
e:
>> >> 2011/5/12 =A0<frank.blaschka@de.ibm.com>:
>> >> > Set rx csum default to hw checksumming again.
>> >> > Remove sysfs interface for rx csum (checksumming) and TSO (larg=
e_send).
>> >> > With the new hw_features it does not work to keep the old sysfs
>> >> > interface in parallel. Convert options.checksum_type to new hw_=
features.
>> >> [...]
>> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* hw may have changed during off=
line or recovery */
>> >> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!qeth_is_supported(card, IPA_=
INBOUND_CHECKSUM)) {
>> >> [...]
>> >>
>> >> This check should go to ndo_fix_features callback. If it fails th=
en
>> >> just return features &~NETIF_F_RXCSUM from there ...
>> >>
> Ok so all I have to do to complete this is to remove
> =A0card->dev->hw_features &=3D ~NETIF_F_RXCSUM;
> from here (ndo_fix_feature has already the check)?
>
> Since we might be in recovery it is smarter to keep the support check=
 here so we
> do not have to use try and error approach to see if capabilities have
> changed. Do you aggree?

The key is that the driver should call netdev_update_features()
whenever some conditions affecting available features might have
changed. If you can keep the checks contained inside ndo_fix_features
callback, you can avoid caring about the offloads in the recovery
process.

There's also the question what happens when packets are queued while
there's ongoing recovery? Simplest way would be to drop them all until
recovery completes.

Best Regards,
Micha=B3 Miros=B3aw
