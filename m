From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH 1/7] CAN: Allocate protocol numbers for PF_CAN
Date: Tue, 2 Oct 2007 11:11:38 -0300
Message-ID: <20071002141138.GD7881@ghostprotocols.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131107.31727.1@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:29898 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbXJBOLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:11:50 -0400
Received: by nf-out-0910.google.com with SMTP id g13so3258918nfb
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 07:11:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20071002131107.31727.1@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, Oct 02, 2007 at 03:10:07PM +0200, Urs Thuermann escreveu:
> This patch adds a protocol/address family number, ARP hardware type,
> ethernet packet type, and a line discipline number for the SocketCAN
> implementation.
> 
> Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
> 
> ---
>  include/linux/if.h       |    4 +++-
>  include/linux/if_arp.h   |    1 +
>  include/linux/if_ether.h |    1 +
>  include/linux/socket.h   |    2 ++
>  include/linux/tty.h      |    3 ++-
>  net/core/sock.c          |    4 ++--
>  6 files changed, 11 insertions(+), 4 deletions(-)
> 
> Index: net-2.6.24/include/linux/if_arp.h
> ===================================================================
> --- net-2.6.24.orig/include/linux/if_arp.h	2007-10-02 12:10:51.000000000 +0200
> +++ net-2.6.24/include/linux/if_arp.h	2007-10-02 12:11:01.000000000 +0200
> @@ -52,6 +52,7 @@
>  #define ARPHRD_ROSE	270
>  #define ARPHRD_X25	271		/* CCITT X.25			*/
>  #define ARPHRD_HWX25	272		/* Boards with X.25 in firmware	*/
> +#define ARPHRD_CAN	280		/* Controller Area Network      */

Is 280 used in other OS? Just curious as why not using 273

>  #define ARPHRD_PPP	512
>  #define ARPHRD_CISCO	513		/* Cisco HDLC	 		*/
>  #define ARPHRD_HDLC	ARPHRD_CISCO
> Index: net-2.6.24/include/linux/if_ether.h
> ===================================================================
> --- net-2.6.24.orig/include/linux/if_ether.h	2007-10-02 12:10:51.000000000 +0200
> +++ net-2.6.24/include/linux/if_ether.h	2007-10-02 12:11:01.000000000 +0200
> @@ -90,6 +90,7 @@
>  #define ETH_P_WAN_PPP   0x0007          /* Dummy type for WAN PPP frames*/
>  #define ETH_P_PPP_MP    0x0008          /* Dummy type for PPP MP frames */
>  #define ETH_P_LOCALTALK 0x0009		/* Localtalk pseudo type 	*/
> +#define ETH_P_CAN	0x000C		/* Controller Area Network      */
>  #define ETH_P_PPPTALK	0x0010		/* Dummy type for Atalk over PPP*/
>  #define ETH_P_TR_802_2	0x0011		/* 802.2 frames 		*/
>  #define ETH_P_MOBITEX	0x0015		/* Mobitex (kaz@cafe.net)	*/
> Index: net-2.6.24/include/linux/socket.h
> ===================================================================
> --- net-2.6.24.orig/include/linux/socket.h	2007-10-02 12:10:51.000000000 +0200
> +++ net-2.6.24/include/linux/socket.h	2007-10-02 12:11:01.000000000 +0200
> @@ -185,6 +185,7 @@
>  #define AF_PPPOX	24	/* PPPoX sockets		*/
>  #define AF_WANPIPE	25	/* Wanpipe API Sockets */
>  #define AF_LLC		26	/* Linux LLC			*/
> +#define AF_CAN		29	/* Controller Area Network      */

Ditto

>  #define AF_TIPC		30	/* TIPC sockets			*/
>  #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
>  #define AF_IUCV		32	/* IUCV sockets			*/
> @@ -220,6 +221,7 @@
>  #define PF_PPPOX	AF_PPPOX
