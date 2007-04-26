From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] usb-net/pegasus: simplify carrier detection
Date: Thu, 26 Apr 2007 12:12:15 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0704261211170.9967@bender.nucleusys.com>
References: <1177424406.13684.5.camel@localhost.localdomain>
 <462E3508.1030703@garzik.org> <20070424170429.GA13668@kroah.com>
 <58298.85.91.128.158.1177436881.squirrel@nucleusys.com>
 <1177446286.18030.13.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704251648050.16498@bender.nucleusys.com>
 <1177513723.3612.0.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704251808210.16498@bender.nucleusys.com>
 <1177516990.3612.2.camel@localhost.localdomain>  <462F7B9A.2090904@garzik.org>
 <1177551029.1684.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n152-u15.estnet.bg ([89.253.152.15]:4438 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754782AbXDZJKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 05:10:41 -0400
In-Reply-To: <1177551029.1684.2.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Good man, I owe you a beer. :)


cheers,
Petko



On Wed, 25 Apr 2007, Dan Williams wrote:

> Simplify pegasus carrier detection; rely only on the periodic MII
> polling.  Reverts pieces of c43c49bd61fdb9bb085ddafcaadb17d06f95ec43.
>
> Signed-off-by: Dan Williams <dcbw@redhat.com>
>
> --- a/drivers/usb/net/pegasus.h	2007-04-25 21:21:00.000000000 -0400
> +++ b/drivers/usb/net/pegasus.h	2007-04-25 21:21:13.000000000 -0400
> @@ -11,7 +11,6 @@
>
> #define	PEGASUS_II		0x80000000
> #define	HAS_HOME_PNA		0x40000000
> -#define	TRUST_LINK_STATUS	0x20000000
>
> #define	PEGASUS_MTU		1536
> #define	RX_SKBS			4
> @@ -204,7 +203,7 @@
> PEGASUS_DEV( "Allied Telesyn Int. AT-USB100", VENDOR_ALLIEDTEL, 0xb100,
> 		DEFAULT_GPIO_RESET | PEGASUS_II )
> PEGASUS_DEV( "Belkin F5D5050 USB Ethernet", VENDOR_BELKIN, 0x0121,
> -		DEFAULT_GPIO_RESET | PEGASUS_II | TRUST_LINK_STATUS )
> +		DEFAULT_GPIO_RESET | PEGASUS_II )
> PEGASUS_DEV( "Billionton USB-100", VENDOR_BILLIONTON, 0x0986,
> 		DEFAULT_GPIO_RESET )
> PEGASUS_DEV( "Billionton USBLP-100", VENDOR_BILLIONTON, 0x0987,
> --- a/drivers/usb/net/pegasus.c	2007-04-25 21:20:32.000000000 -0400
> +++ b/drivers/usb/net/pegasus.c	2007-04-25 21:22:15.000000000 -0400
> @@ -848,16 +848,6 @@
> 		 * d[0].NO_CARRIER kicks in only with failed TX.
> 		 * ... so monitoring with MII may be safest.
> 		 */
> -		if (pegasus->features & TRUST_LINK_STATUS) {
> -			if (d[5] & LINK_STATUS)
> -				netif_carrier_on(net);
> -			else
> -				netif_carrier_off(net);
> -		} else {
> -			/* Never set carrier _on_ based on ! NO_CARRIER */
> -			if (d[0] & NO_CARRIER)
> -				netif_carrier_off(net);
> -		}
>
> 		/* bytes 3-4 == rx_lostpkt, reg 2E/2F */
> 		pegasus->stats.rx_missed_errors += ((d[3] & 0x7f) << 8) | d[4];
>
>
>
