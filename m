From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] Add support for RX packet classification in
	a	network device
Date: Tue, 23 Dec 2008 00:16:48 +0000
Message-ID: <1229991408.3077.19.camel@achroite>
References: <494FE060.8020600@Sun.COM> <1229974033.3077.14.camel@achroite>
	 <49501CEF.8010101@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	gkernel-commit@lists.sourceforge.net,
	Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>
To: Santwona.Behera@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:56785 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755471AbYLWARI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 19:17:08 -0500
In-Reply-To: <49501CEF.8010101@Sun.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-22 at 15:04 -0800, Santwona.Behera@Sun.COM wrote:
[...]
> >> @@ -558,14 +626,16 @@ struct ethtool_ops {
> >>  #define        TCP_V4_FLOW     0x01
> >>  #define        UDP_V4_FLOW     0x02
> >>  #define        SCTP_V4_FLOW    0x03
> >> -#define        AH_ESP_V4_FLOW  0x04
> >> -#define        TCP_V6_FLOW     0x05
> >> -#define        UDP_V6_FLOW     0x06
> >> -#define        SCTP_V6_FLOW    0x07
> >> -#define        AH_ESP_V6_FLOW  0x08
> >> +#define        AH_V4_FLOW      0x04
> >> +#define        ESP_V4_FLOW     0x05
> >> +#define        TCP_V6_FLOW     0x06
> >> +#define        UDP_V6_FLOW     0x07
> >> +#define        SCTP_V6_FLOW    0x08
> >> +#define        AH_V6_FLOW      0x09
> >> +#define        ESP_V6_FLOW     0x0a
> >> +#define        IP_USER_FLOW    0x0b
> >>  
> >>  /* L3-L4 network traffic flow hash options */
> >> -#define        RXH_DEV_PORT    (1 << 0)
> >>  #define        RXH_L2DA        (1 << 1)
> >>  #define        RXH_VLAN        (1 << 2)
> >>  #define        RXH_L3_PROTO    (1 << 3)
> > [...]
> > 
> > No, you can't do this.  Leave the existing definitions unchanged and
> > only add new ones.
> 
> The original code/patch was not quite correct where the AH_ESP_V4_FLOW 
> was being used to represent AH flows. So my goal here was to remove that 
> and add 2 separate flow types for AH and ESP. I have two ways of 
> achieving this without changing the existing definitions completely:
> 
> 1. I change AH_ESP_Vx_FLOW defines to AH_Vx_FLOW defines and add 2 new 
> defines for ESP_Vx_FLOW at the end, with values 0x9 and 0xa.

If AH_ESP_Vx_FLOW has only ever been implemented as AH-only then perhaps
this is reasonable.

> 2. I keep the AH_ESP_Vx_FLOW defines as is (but this will be dead code 
> as it will not be used) and add 2 new AH_Vx_FLOW defines and 2 new 
> ESP_Vx_FLOW defines at the end with values 0x9, 0xa, 0xb, 0xc.

This is safest.

Also you are probably right to remove RXH_DEV_PORT as that appears to be
an niu quirk that shouldn't be exposed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

