From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: Gianfar : Drop a long frame
Date: Wed, 30 Jan 2013 17:55:44 +0200
Message-ID: <51094280.8060701@freescale.com>
References: <001a01cdfeef$cdc5bee0$69513ca0$@acksys.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: voncken <cedric.voncken@acksys.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:53943
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755298Ab3A3P4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 10:56:50 -0500
In-Reply-To: <001a01cdfeef$cdc5bee0$69513ca0$@acksys.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/2013 3:43 PM, voncken wrote:
> 	Hi Claudiu,
>
> 	I have a problem with the gianfar driver.
>
> 	My test conditions are:
> 		- Disable rxvlan hardware acceleration (ethtool -K ethx
> rxvlan off)
> 		- Receive frame contains a VLAN tag and with a frame len set
> to the MTU (1500 bytes).
>
> 	In this condition, when I received a long frame the bdp->length is
> set to 1538 bytes.
> 	I guess it is composed of:
> 		1500 bytes: L3 data bytes
> 		 + 14 bytes:  Ethernet header
> 		 + 4 bytes:  Vlan Tag header
> 		 + 8 bytes: FCB structure size GMAC_FCB_LEN
> 		 + 8 bytes: eTSEC padding
> 		 + 4 bytes: Frames CRC (FCS)
>
> 	The Maximum frame len is set to 1536 because the function
> gfar_change_mtu does not integrate the FCS in the computed frame size.
> 	In this condition this frame is dropped with the test line 2792
> function gfar_clean_rx_ring
> 		if (unlikely(!(bdp->status & RXBD_ERR) &&
> 				bdp->length > priv->rx_buffer_size))
> 			bdp->status = RXBD_LARGE;
> 	
> 	How I can receive this frame correctly?
> 	
> 	Best regards
>
> Cedric Voncken | R&d Engineer

Hi Cedric Voncken,
Is the 802.1Q support activated on the receiving host? (see
CONFIG_VLAN_8021Q)
