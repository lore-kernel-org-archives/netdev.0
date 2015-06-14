From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] bridge: del external_learned fdbs from device on
 flush or ageout
Date: Sun, 14 Jun 2015 16:19:57 -0700
Message-ID: <CAE4R7bBCLchGyTY9Zdexd9BE+33Tqua0CY9K75iRc6sOrMYwFg@mail.gmail.com>
References: <1434306791-43364-1-git-send-email-sfeldma@gmail.com> <CAKoUArkKtWyRyDHc2R03xk5TixMKOG+66_prPrycs2rU0wYpJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Rami Rosen <roszenrami@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:33156 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbFNXUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jun 2015 19:20:18 -0400
Received: by qged89 with SMTP id d89so2328500qge.0
        for <netdev@vger.kernel.org>; Sun, 14 Jun 2015 16:20:17 -0700 (PDT)
In-Reply-To: <CAKoUArkKtWyRyDHc2R03xk5TixMKOG+66_prPrycs2rU0wYpJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 14, 2015 at 3:14 PM, Rami Rosen <roszenrami@gmail.com> wrote:
> Hi,
>
> You mention bridge doing ageing vs. device doing
> ageing. AFAIK, there is no way to prevent a bridge from doing aging by
> a sysfs entry. Do you think that preventing bridge aging via sysfs is
> needed?

The topic has been discussed before, but not at the patch level, yet,
AFIAK.  I had this XXX comment in
Documentation/networking/switchdev.txt:

     XXX: how to turn off ageing in kernel on a per-port basis or
otherwise prevent the kernel from ageing out the FDB entry?

I think the preference would be to use netlink over sysfs.  If we made
this a per-port flag, we could add bool IFLA_BRPORT_AGEING flag (and
BR_AGEING) for IFLA_PROTINFO.

There is also the need to push the bridge's ageing timeout value down
to the device.  This could be done with switchdev attr, e.g.
SWITCHDEV_ATTR_AGEING_TIMEOUT.  (Maybe there is already netlink
plumbing to do this...need to check).

Are you going to work on it?  ;)

-scott
