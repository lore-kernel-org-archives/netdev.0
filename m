From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 01:42:24 -0700
Message-ID: <CAE4R7bD0Ka0187Qq=+6cZL7UqgnxJASKL_6AmaC2z_jiF5Jp1w@mail.gmail.com>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com> <20150827074525.GA8094@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:36132 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbbH0Imp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 04:42:45 -0400
Received: by obkg7 with SMTP id g7so10454074obk.3
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 01:42:44 -0700 (PDT)
In-Reply-To: <20150827074525.GA8094@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 12:45 AM, Andrew Lunn <andrew@lunn.ch> wrote:
>> I don't know about how this overlaps with DSA platform_class.  Florian?
>
> There is some overlap with DSA, but the current DSA model, with
> respect to probing, is broken. So this might be interesting as a way
> towards fix that.
>
> One thing to keep in mind is the D in DSA. You talk about switch,
> singular. DSA has a number of switches in a cluster. We currently
> export a single switchdev interface for the cluster, but there are
> some properties which are per switch, e.g. temperature, eeprom
> contents, statistics, power management etc.

Export a single 'switchdev' or 'netdev' for the cluster?  I hope that
was a typo.  With switchdev device class, you'd instantiate one per
phy switch, and have per-switch props (temp, eeprom, etc) thru each
switchdev instance.  The cluster netdev would stay a netdev which
spans the switches.

>
> Although ethtool does have options for these, it is not always a
> natural fit. ethtool --eeprom-dump on a switch port dumps the switch
> EEPROM, and all ports on the switch can be used. --register-dump on a
> port is good for showing the per ports registers, but there is no
> natural interface for showing the global switch registers. Florian's
> resent L2 interface patch shows we have issues getting access to the
> 'cpu' port, the port which interfaces to the host.
>
> We need to be careful that any new interfaces we add are better at
> representing the true structure of the hardware, which includes there
> being multiple physical switches below a switchdev, and they are
> connected together by ports which are currently not visible as
> netdevs.

Right.  I'm thinking one switchdev instance (based on the new
switchdev class) per phy switch.  Port netdevs for switch ports worth
exposing (for user interaction).  And cluster netdev for dsa tagging
encap/decap.  Do I have this right?
