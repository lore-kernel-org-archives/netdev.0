From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Fri, 27 Mar 2015 16:19:23 -0700
Message-ID: <CAE4R7bCO4QczefdR7NSyuqzV5i8gp1W2=SzU3yrBCyKB65muzQ@mail.gmail.com>
References: <20150324175825.GA1465@roeck-us.net>
	<CAE4R7bAoGeFdNAUqMR-RmQWTtfSy0t+e4f187an_BVVVR2tDnw@mail.gmail.com>
	<CAGVrzcZ+QywZxe4P2bcnBLG9mXUDARNzNyXF1yTOV9tnAcx=PQ@mail.gmail.com>
	<CAE4R7bBeFg9v-CnUJU-0pe8ZS4AYXQNAGNTcvCrHdZ1ggYmOPA@mail.gmail.com>
	<5512E9EC.5020504@cumulusnetworks.com>
	<CAE4R7bCtpaonLeRiX9s3yFisONDQUv9z_EOBcGTdgTGLEjC7vA@mail.gmail.com>
	<20150326082011.GA2010@nanopsycho.orion>
	<CAE4R7bCYe1c2dT0V3tDjUvVuzB28WabAjbt=sQreK=3WM+60Nw@mail.gmail.com>
	<20150326144922.GC2010@nanopsycho.orion>
	<CAE4R7bCiwq6RjQ06UM2FFX1EzCrjrd=fHz0gcJzgcmPJ73hSHg@mail.gmail.com>
	<20150327070102.GD2073@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roopa <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:32938 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbbC0XTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 19:19:24 -0400
Received: by qgfa8 with SMTP id a8so140204578qgf.0
        for <netdev@vger.kernel.org>; Fri, 27 Mar 2015 16:19:23 -0700 (PDT)
In-Reply-To: <20150327070102.GD2073@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 12:01 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Fri, Mar 27, 2015 at 07:43:35AM CET, sfeldma@gmail.com wrote:
>>On Thu, Mar 26, 2015 at 7:49 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Thu, Mar 26, 2015 at 03:28:28PM CET, sfeldma@gmail.com wrote:
>>
>>>>What is the argument for not allowing stacked version of swdev_parent_id_get()?
>>>
>>> That was suppose wo identify a switch port. "ip link" will show you that
>>> and you see right away what is going on. If bond implements that, that
>>> brigs a mess. I don't like that.
>>
>>A bond is an aggregator of ports and showing switch_id for bond is no
>>more messy than showing link speed for bond, derived from link speed
>>on member ports.
>
> Well, I don't think so. I think the switchid should be showed on port
> devices only.

That's doable by making switchid sysfs and netlink interfaces (the
user-visible interfaces) not recurse, and for internal usage, to get
switchid of aggregate device, allow recursion.  I'll be posting
patches soon so you'll see what I mean from code.

> Please remind me why exactly you need this?

Central theme of this thread: to know if bcast/mcast/unknown ucast
pkts should be flooded by bridge or not on ports hardware may have
already flooded.

> Also should switch id be showed on other devices? Like bridges, vlans,
> macvlans, etc?
> For bond it sometimes will be shown (2ports of the same switch)
> sometimes not (2ports each of the different switch).
> That looks messy to me. I might be wrong of course...

No problem, we'll make only the base port device show switchid.

-scott
