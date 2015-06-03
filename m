From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 7/9] net: dsa: mv88e6352: lock CPU port from learning addresses
Date: Tue, 02 Jun 2015 21:17:24 -0700
Message-ID: <556E7FD4.3040200@roeck-us.net>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>	<1433208470-25338-8-git-send-email-vivien.didelot@savoirfairelinux.com>	<556DBCA4.10203@roeck-us.net>	<1317462817.952931.1433293575321.JavaMail.zimbra@savoirfairelinux.com>	<20150603022451.GB932@roeck-us.net> <CAFXsbZo7DAhbUErMfKas_KUtXMHTURgOxwz-GSr=fuAHLWToEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	David <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	=?UTF-8?B?SsOpcm9tZSBPdWZlbGxh?=
	<jerome.oufella@savoirfairelinux.com>,
	kernel <kernel@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:53370 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbbFCER3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 00:17:29 -0400
In-Reply-To: <CAFXsbZo7DAhbUErMfKas_KUtXMHTURgOxwz-GSr=fuAHLWToEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2015 07:31 PM, Chris Healy wrote:
> Guenter,
>
> That's a very valid concern.  I have a configuration with a 6352 controlled by a low end ARM core with a 100mbps connection on the CPU port.  This switch needs to support passing multicast streams that are more than 100mbps on GigE links.  (The ARM does not need to consume the multicast, it just manages the switch.)
>

Possibly, but Vivien didn't answer my question (how the local SA address finds
its way into the switch fdb). I'll check it myself.

Thanks,
Guenter

> On Jun 3, 2015 3:24 AM, "Guenter Roeck" <linux@roeck-us.net <mailto:linux@roeck-us.net>> wrote:
>
>     On Tue, Jun 02, 2015 at 09:06:15PM -0400, Vivien Didelot wrote:
>      > Hi Guenter,
>      >
>      > On Jun 2, 2015, at 10:24 AM, Guenter Roeck linux@roeck-us.net <mailto:linux@roeck-us.net> wrote:
>      > On 06/01/2015 06:27 PM, Vivien Didelot wrote:
>      > >> This commit disables SA learning and refreshing for the CPU port.
>      > >>
>      > >
>      > > Hi Vivien,
>      > >
>      > > This patch also seems to be unrelated to the rest of the series.
>      > >
>      > > Can you add an explanation why it is needed ?
>      > >
>      > > With this in place, how does the CPU port SA find its way into the fdb ?
>      > > Do we assume that it will be configured statically ?
>      > > An explanation might be useful.
>      >
>      > Without this patch, I noticed the CPU port was stealing the SA of a PC
>      > behind a switch port. this happened when the port was a bridge member,
>      > as the bridge was relaying broadcast coming from one switch port to the
>      > other switch ports in the same vlan.
>      >
>     Makes me feel really uncomfortable. I think we may be going into the wrong
>     direction. The whole point of offloading bridging is to have the switch handle
>     forwarding, and that includes multicasts and broadcasts. Instead of doing that,
>     it looks like we put more and more workarounds in place.
>
>     Maybe the software bridge code needs to understand that it isn't support to
>     forward broadcasts to ports of an offloaded bridge, and we should let the
>     switch chip handle it ?
>
>     Thanks,
>     Guenter
>
