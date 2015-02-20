From: Viswanath Bandaru <vbandaru@broadcom.com>
Subject: RE: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Fri, 20 Feb 2015 03:53:34 +0000
Message-ID: <FFEDCF9956066D4D97C463CC178C7F69F21C8A@SJEXCHMB06.corp.ad.broadcom.com>
References: <54E54EF3.9020802@gmail.com>
 <20150219055953.GA14247@roeck-us.net> <54E61CFB.3010109@gmail.com>
 <20150219174640.GA6897@roeck-us.net> <54E676DD.9090003@gmail.com>
 <20150220000935.GA30118@roeck-us.net> <54E68512.6070108@cumulusnetworks.com>
 <20150220010352.GA300@roeck-us.net> <54E691F2.5090205@cumulusnetworks.com>
 <54E69536.3040303@gmail.com> <20150220032058.GL580@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: roopa <roopa@cumulusnetworks.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"vivien.didelot@savoirfairelinux.com"
	<vivien.didelot@savoirfairelinux.com>,
	"jerome.oufella@savoirfairelinux.com"
	<jerome.oufella@savoirfairelinux.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"cphealy@gmail.com" <cphealy@gmail.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64526 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbbBTDxo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 22:53:44 -0500
In-Reply-To: <20150220032058.GL580@gospo.home.greyhouse.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Andy Gospodarek
> Sent: Friday, February 20, 2015 8:51 AM
> To: Florian Fainelli
> Cc: roopa; Guenter Roeck; netdev@vger.kernel.org; davem@davemloft.net;
> vivien.didelot@savoirfairelinux.com; jerome.oufella@savoirfairelinux.com;
> andrew@lunn.ch; cphealy@gmail.com
> Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
> operations
> 
> On Thu, Feb 19, 2015 at 06:00:22PM -0800, Florian Fainelli wrote:
> > On 19/02/15 17:46, roopa wrote:
> > > On 2/19/15, 5:03 PM, Guenter Roeck wrote:
> > >> On Thu, Feb 19, 2015 at 04:51:30PM -0800, roopa wrote:
> > >>>> Not sure yet what to do about setting the fdb aging time. I don't
> > >>>> see a mechanism to do that. No idea how important that is.
> > >>> rocker, the only consumer today relies on the bridge driver aging
> > >>> of learnt entries.
> > >>> You could do the same.
> > >>>
> > >> Remember that we are dealing with hardware switch chips. Those
> > >> chips won't time out fdb entries just because the kernel's bridge
> > >> driver thinks that it should.
> > > Oh, they dont..?. sorry,  I dont know the details about your hardware.
> > > But, if these are entries learnt by hw, there should be a hw config
> > > to age them (I guess that is what you are talking about). Which the
> > > swicth driver can set.
> > > If you disable hw aging, you can sync these entries to the bridge
> > > driver, and make the bridge driver age them followed by a subsequent
> > > delete in hw.
> >
> > The SF2 HW has and aging and a valid bit available, I guess my
> > question would be, do we have anything today in "net-next" that allows
> > configuring HW aging vs. SW aging (implying doing a HW to SW sync)?
> 
> Yes, the setting of the BR_LEARNING_SYNC bit in bridge port flags should
> signal to the hardware that it should send learning notifications up to the
> kernel bridge.  This is set via the IFLA_BRPORT_LEARNING attribute in a
> setlink message.
> 

We had a recent discussion on this subject on roker and ageing.  Siva submitted a patch for bridge not to age the 'externally learnt entries'. This broke Rocker because it depended on bridge to age out entries even if they are 'externally learnt'. 

After some discussion, Scott agreed that rocker should also take care of ageing out the entries (in addition to learning them), just like a real silicon would do.  He is going to submit a patch for Rocker soon.

Vissu

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
