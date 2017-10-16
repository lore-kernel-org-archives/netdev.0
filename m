From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 2/4] net: dsa: mv88e6060: setup random mac
 address
Date: Mon, 16 Oct 2017 09:02:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0097980@AcuExch.aculab.com>
References: <20171013014113.29561-1-vivien.didelot@savoirfairelinux.com>
 <20171013014113.29561-3-vivien.didelot@savoirfairelinux.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0094F25@AcuExch.aculab.com>
 <9235D6609DB808459E95D78E17F2E43D40B512EB@CHN-SV-EXMX02.mchp-main.com>
 <871sm7j8ub.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <9235D6609DB808459E95D78E17F2E43D40B51650@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>
To: "'Woojung.Huh@microchip.com'" <Woojung.Huh@microchip.com>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40B51650@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Woojung.Huh@microchip.com
> Sent: 13 October 2017 18:59
> > >> > +	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, (addr[0] << 9) |
> > >> addr[1]);
> > >>
> > >> Is that supposed to be 9 ?
> > >
> > > Looks like it.
> > > Check
> > http://www.marvell.com/switching/assets/marvell_linkstreet_88E6060_data
> > sheet.pdf
> >
> > Hum, David is correct, there is a bug in the driver which needs to be
> > addressed first. MAC address bit 40 is addr[0] & 0x1, thus we must
> > shift byte 0 by 8 and mask it against 0xfe.
> >
> > I'll respin this serie including a fix for both net and net-next.
> 
> Yes, you are right. Missed description about bit 40.

Since they are all random numbers it doesn't matter.

Actually isn't this just masking off the non-unicast bit?
So it won't be set in the data - and so doesn't need masking.

	David
