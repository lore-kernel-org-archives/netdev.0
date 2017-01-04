From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] net: ethernet: faraday: To support device tree usage.
Date: Wed, 04 Jan 2017 14:23:15 +0100
Message-ID: <4553002.lqp6KanHTq@wuerfel>
References: <1483083470-15779-1-git-send-email-green.hu@gmail.com> <2299808.LHnPolcyRJ@wuerfel> <CAEbi=3f7pf59YjNha-bpK+GZw4BSdevngi=fekd9uNLMVXDVnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, devicetree@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
        Jiri Pirko <jiri@resnulli.us>, jonas.jensen@gmail.com,
        davem@davemloft.net
To: Greentime Hu <green.hu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEbi=3f7pf59YjNha-bpK+GZw4BSdevngi=fekd9uNLMVXDVnQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, January 4, 2017 9:49:51 AM CET Greentime Hu wrote:
> On Tue, Jan 3, 2017 at 9:24 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > On Tuesday, January 3, 2017 2:05:47 PM CET Greentime Hu wrote:
> > > ​I am not sure if atmac and moxa-art are exactly hardware compatible
> > though
> > > they are based on faraday ftmac.
> > > It may be better if we use 2 different device tree binding documents to
> > > describe for these 2 different drivers to use.
> >
> > They are probably slightly different, but close enough to have the same
> > binding document, as there is no technical reason to have two separate
> > drivers for them. The binding should be about the hardware type, not the
> > way that Linux currently implements the drivers.
> >
> >         Arnd
> >
> >
> OK.
> 
> How about this?
> 
> rename
> Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
> to
> Documentation/devicetree/bindings/net/faraday,ftmac.txt
> 
> and the content to
> Faraday Ethernet Controller

Sounds good. Note that you can use 'git patch -M' to produce
this as a renaming patch.

> 
> Required properties:
> 
> - compatible : Must be "moxa,moxart-mac" or "andestech,atmac" or
> "faraday,ftmac"

I'd write this as

	compatible: Must contain "faraday,ftmac", as well as one of
	            the SoC specific identifiers:
			"andestec,atmac"
			"moxa,moxart-mac"

This makes it easier to extend, plus it makes the generic string
mandatory.

	Arnd
