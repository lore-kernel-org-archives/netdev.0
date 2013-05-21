From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2 net-next] phy: allow flagging a device as internal
Date: Tue, 21 May 2013 18:48:02 +0100
Message-ID: <1369158482.2615.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <1369132626-13776-1-git-send-email-f.fainelli@gmail.com>
	 <1369154667.2615.17.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAGVrzcbN1LLdC6ASLhk4e+33pr4aP3xBeycQ_kiL09VxVTmitg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<afleming@freescale.com>, <jogo@openwrt.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55553 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752024Ab3EURsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 13:48:05 -0400
In-Reply-To: <CAGVrzcbN1LLdC6ASLhk4e+33pr4aP3xBeycQ_kiL09VxVTmitg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 18:25 +0100, Florian Fainelli wrote:
> 2013/5/21 Ben Hutchings <bhutchings@solarflare.com>
>         On Tue, 2013-05-21 at 11:37 +0100, Florian Fainelli wrote:
>         > David, Andy,
>         >
>         > This small patch set updates libphy to allow PHY drivers to
>         flag a
>         > specific PHY device as internal, which is then used to
>         accurately
>         > report the transceiver type (internal vs external) in
>         ethtool.
>         >
>         > As far as I can tell we only have one in-tree driver for the
>         moment
>         > which is known to be for internal PHYs.
>         
>         
>         I don't think you should make any change like this until there
>         is proper
>         documentation of what the 'transceiver' field actually means.
>         
>         It appears that XCVR_EXTERNAL was originally used for a
>         transceiver
>         module external to the system, usually connected to an AUI
>         port.  The
>         modern equivalent of that might be SFP+ and similar module
>         slots, but
>         they're a bit different because the Physical Coding Sublayer
>         is usually
>         part of the controller.
>         
>         Many newer drivers are using XCVR_EXTERNAL to indicate that
>         the PHY is a
>         separate package from the controller, which is what you seem
>         to be doing
>         here.  But nowhere is that specified!
> 
> 
> Well, it depends how you define "specified", I can see quite a lot of
> drivers actually defining it to match the definition you gave above,
> so the de facto situation is like you describe it.

I would like to see someone (you?) provide a longer comment in ethtool.h
that says what XCVR_INTERNAL and XCVR_EXTERNAL are supposed to mean (the
other values are obviously driver-specific so don't matter as much).

>         The transceiver field doesn't even really matter much unless
>         the user
>         has a choice of which to use. 
> 
> 
> This is about reporting accurate information, the field is not
> user-changeable using libphy's ethtool knobs.

The information cannot be accurate without also being clear.

>         Does anyone make boards like that any
>         more?  And it's probably entirely redundant with the port and
>         phy_address fields in that case, anyway.
> 
> 
> At least I need to know from my driver if the PHY is an internal one
> (package perspective) or not because there is a different
> configuration path depending on this. I could just drop the hunk which
> sets cmd->transceiver then.

I think that makes more sense.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
