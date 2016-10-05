From: Nelson Chang <nelson.chang@mediatek.com>
Subject: RE: [PATCH net-next v2 2/3] net: ethernet: mediatek: get hw lro
 capability by the chip id instead of by the dtsi
Date: Wed, 5 Oct 2016 21:21:18 +0800
Message-ID: <1475673678.6101.11.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>
To: <David.Laight@ACULAB.COM>, <sergei.shtylyov@cogentembedded.com>,
        <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:31982 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754240AbcJENVY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 09:21:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei, David,

I think modifying that as below is clear and scalable. Agree?

static bool mtk_is_hwlro_supported(struct mtk_eth *eth)
{
	switch (eth->chip_id) {
	case MT7623_ETH:
		return true;
	}

	return false;
}

Thanks.


Nelson
-----Original Message-----
From: David Laight [mailto:David.Laight@ACULAB.COM] 
Sent: Wednesday, October 05, 2016 9:07 PM
To: Nelson Chang (張家祥); sergei.shtylyov@cogentembedded.com;
john@phrozen.org; davem@davemloft.net
Cc: nbd@openwrt.org; netdev@vger.kernel.org;
linux-mediatek@lists.infradead.org; nelsonch.tw@gmail.com
Subject: RE: [PATCH net-next v2 2/3] net: ethernet: mediatek: get hw lro
capability by the chip id instead of by the dtsi

From: Nelson Chang
> Sent: 05 October 2016 13:46
> > +static bool mtk_is_hwlro_supported(struct mtk_eth *eth) {
> > +     if (eth->chip_id == MT7623_ETH)
> > +             return true;
> > +     else
> > +             return false;
> 
>         return eth->chip_id == MT7623_ETH;
> 
> => Since there will be more chips support hw lro in the future, keep 
> the original codes to have the scalability like this:
> if (eth->chip_id == MTxxxx_ETH ||
>     eth->chip_id == MTyyyy_ETH ||
>     ....)
> 	return true;

Nothing wrong with:

	return eth->chip_id == MTxxxx_ETH ||
		eth->chip_id == MTyyyy_ETH;

	David
