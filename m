From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/1] net: Set NOCARRIER bit of etherdev state at
 initialization
Date: Tue, 27 May 2014 10:24:20 -0500
Message-ID: <1401204260.4346.11.camel@dcbw.local>
References: <537F7EEF.3060701@gmail.com>
	 <1400866681.18322.27.camel@dcbw.local>
	 <20140523.141551.1253983630587935706.davem@davemloft.net>
	 <CAHPKR9LUseeYbtJomZHSu0mmU-VbcCVg8OGnSCOL1b1=Sfj9kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	Avinash Kumar <avi.kp.137@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Balakumaran Kannan <kumaran.4353@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912AbaE0PYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 11:24:31 -0400
In-Reply-To: <CAHPKR9LUseeYbtJomZHSu0mmU-VbcCVg8OGnSCOL1b1=Sfj9kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-05-24 at 18:52 +0530, Balakumaran Kannan wrote:
> On Fri, May 23, 2014 at 11:45 PM, David Miller <davem@davemloft.net> wrote:
> > From: Dan Williams <dcbw@redhat.com>
> > Date: Fri, 23 May 2014 12:38:01 -0500
> >
> >> The current "carrier on until told otherwise" model is intentional,
> >> because not all drivers support carrier detection, and thus we must
> >> assume the carrier is on until the driver tells us it is not on.
> >>
> >> Would this patch break that model?
> >
> > Absolutely correct, this change is completely inappropriate.
> 
> So it is driver's responsibility to maintain this flag appropriately.
> Thus if a driver supports carrier detection, it should set "carrier
> on" only after determining the carrier state. Then I'll add
> 'netif_carrier_off' call to smsc911x driver and send a new patch.

Correct.  Carrier state starts with ON.  If the driver knows it can
detect carrier state, then the driver should call netif_carrier_off()
early in the driver initialization, and then call on/off as appropriate
when it gets carrier change events.

Dan

> Thanks for the explanation.
> 
> Regards,
> K.Balakumaran
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
