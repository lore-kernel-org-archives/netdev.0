From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH RFC 24/30] net: fec: better implementation of iMX6
	ERR006358 quirk
Date: Wed, 25 Jun 2014 01:41:21 +0000
Message-ID: <692507cfcb2542e59703ff8f929d9a87@BLUPR03MB373.namprd03.prod.outlook.com>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
 <E1WxxhR-0005YP-Q1@rmk-PC.arm.linux.org.uk>
 <316b383d2512440db51ea7c55992920d@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140622081234.GB32514@n2100.arm.linux.org.uk>
 <56f5e44adf0b41a0bbf52c38b755afbd@BLUPR03MB373.namprd03.prod.outlook.com>
 <20140622084911.GD32514@n2100.arm.linux.org.uk>
 <20140624102912.GM32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0236.outbound.protection.outlook.com ([207.46.163.236]:38954
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754347AbaFYBlY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 21:41:24 -0400
In-Reply-To: <20140624102912.GM32514@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk> Data: Tuesday, June 24, 2014 6:29 PM
>To: Duan Fugang-B38611
>Cc: netdev@vger.kernel.org; linux-arm-kernel@lists.infradead.org
>Subject: Re: [PATCH RFC 24/30] net: fec: better implementation of iMX6
>ERR006358 quirk
>
>On Sun, Jun 22, 2014 at 09:49:11AM +0100, Russell King - ARM Linux wrote:
>> On Sun, Jun 22, 2014 at 08:38:49AM +0000, fugang.duan@freescale.com
>wrote:
>> > From: Russell King - ARM Linux <linux@arm.linux.org.uk> Data:
>> > Sunday, June 22, 2014 4:13 PM
>> > >To: Duan Fugang-B38611
>> > >Cc: linux-arm-kernel@lists.infradead.org; netdev@vger.kernel.org
>> > >Subject: Re: [PATCH RFC 24/30] net: fec: better implementation of
>> > >iMX6
>> > >ERR006358 quirk
>> > >
>> > >On Sun, Jun 22, 2014 at 07:49:11AM +0000, fugang.duan@freescale.com
>wrote:
>> > >> From: Russell King <rmk@arm.linux.org.uk> Data: Friday, June 20,
>> > >> 2014
>> > >> 8:14 PM
>> > >> >To: linux-arm-kernel@lists.infradead.org
>> > >> >Cc: Duan Fugang-B38611; netdev@vger.kernel.org
>> > >> >Subject: [PATCH RFC 24/30] net: fec: better implementation of
>> > >> >iMX6
>> > >> >ERR006358 quirk
>> > >> >
>> > >> >+
>> > >> >+	/* ERR006538: Keep the transmitter going */
>> > >> >+	if (fep->dirty_tx != fep->cur_tx &&
>> > >> >+	    readl(fep->hwp + FEC_X_DES_ACTIVE) == 0)
>> > >> >+		writel(0, fep->hwp + FEC_X_DES_ACTIVE);
>> > >> > }
>> > >> >
>> ...
>> > >While I agree that we can read back to check whether the device
>> > >indicates that transmit is active, there's no point to the other
>> > >tests.  If there are entries in the transmit ring but the
>> > >transmitter indicates that it is not active, then it is obvious
>> > >that the bug has been hit.  This is exactly what my implementation
>above does.
>> > >
>> > The condition "fep->dirty_tx != fep->cur_tx" is not only limited for
>the errata.
>> > I mean only add extra trigger TDAR for the issue.
>>
>> Yes, I agree that test is wrong (that's what comes from shuffling the
>> patches... subsequent patches modify the indexing mechanism).  It
>> should
>> be:
>>
>>         if (bdp != fep->cur_tx &&
>>             readl(fep->hwp + FEC_X_DES_ACTIVE) == 0)
>>                 writel(0, fep->hwp + FEC_X_DES_ACTIVE);
>>
>> Since "bdp" is the post-incremented dirty_tx pointer, which, when it
>> is equal to fep->cur_tx means that the ring is empty.
>
>Any further comments, or do I take the silence to mean that you agree with
>the above statement?  I would like to get this settled to I can spin v2 of
>this set.
>
>Thanks.
>
I agree your statement.

Thanks,
Andy
