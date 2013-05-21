From: Fleming Andy-AFLEMING <afleming@freescale.com>
Subject: Re: [PATCH 0/2 net-next] phy: allow flagging a device as internal
Date: Tue, 21 May 2013 17:35:35 +0000
Message-ID: <AF578243-D545-41ED-8532-1167B2D35154@freescale.com>
References: <1369132626-13776-1-git-send-email-f.fainelli@gmail.com>,<1369154667.2615.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jogo@openwrt.org" <jogo@openwrt.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0184.outbound.messaging.microsoft.com ([213.199.154.184]:8771
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755201Ab3EURfD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 13:35:03 -0400
In-Reply-To: <1369154667.2615.17.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On May 21, 2013, at 11:45, "Ben Hutchings" <bhutchings@solarflare.com> wrote:

> On Tue, 2013-05-21 at 11:37 +0100, Florian Fainelli wrote:
>> David, Andy,
>> 
>> This small patch set updates libphy to allow PHY drivers to flag a
>> specific PHY device as internal, which is then used to accurately
>> report the transceiver type (internal vs external) in ethtool.
>> 
>> As far as I can tell we only have one in-tree driver for the moment
>> which is known to be for internal PHYs.
> 
> I don't think you should make any change like this until there is proper
> documentation of what the 'transceiver' field actually means.
> 
> It appears that XCVR_EXTERNAL was originally used for a transceiver
> module external to the system, usually connected to an AUI port.  The
> modern equivalent of that might be SFP+ and similar module slots, but
> they're a bit different because the Physical Coding Sublayer is usually
> part of the controller.
> 
> Many newer drivers are using XCVR_EXTERNAL to indicate that the PHY is a
> separate package from the controller, which is what you seem to be doing
> here.  But nowhere is that specified!
> 
> The transceiver field doesn't even really matter much unless the user
> has a choice of which to use.  Does anyone make boards like that any
> more?  And it's probably entirely redundant with the port and
> phy_address fields in that case, anyway.


Alas, yes. We have a 10G card that can switch between copper and fiber. But I agree that the field is poorly-defined.

Andy
