From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] s2io: fix inconsistent hardware VLAN tagging during driver init
Date: Fri, 7 Dec 2007 16:02:52 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702A82C8C@nekter>
References: <20071206195713.GA25879@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
To: "Andy Gospodarek" <andy@greyhouse.net>, <netdev@vger.kernel.org>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:54343 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751850AbXLGVDT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 16:03:19 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071206195713.GA25879@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,
This patch looks good. Please accept.

Ram
> -----Original Message-----
> From: Andy Gospodarek [mailto:andy@greyhouse.net]
> Sent: Thursday, December 06, 2007 11:57 AM
> To: netdev@vger.kernel.org
> Cc: ram.vepa@neterion.com; Rastapur Santosh; Sivakumar Subramani;
> Sreenivasa Honnur
> Subject: [PATCH] s2io: fix inconsistent hardware VLAN tagging during
> driver init
> 
> 
> The s2io driver keeps a local variable around (vlan_strip_flag) to
keep
> track of the current state of the hardware and whether or not it will
> strip VLAN tags on incoming packets.  It seems as though the hardware
> default is to strip them, but that variable is not set correctly
during
> initialization if the default setup is used.  This check ensures
> vlan_strip_flag and the hardware setting are in sync.
> 
> These variables were introduced by this patch:
> 
> commit 926930b202d56c3dfb6aea0a0c6bfba2b87a8c03
> Author: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
> Date:   Sat Feb 24 01:59:39 2007 -0500
> 
> so this problem hasn't been around forever.
> 
> Recent patches from Ramkrishna Vepa <ram.vepa@neterion.com> removed
this
> variable and would have worked around the problem, but they were not
> accepted.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> ---
> 
>  s2io.c |    5 +++++
>  1 files changed, 5 insertions(+)
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 8b9f0ea..08c08de 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -2151,6 +2151,11 @@ static int start_nic(struct s2io_nic *nic)
>  		val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
>  		writeq(val64, &bar0->rx_pa_cfg);
>  		vlan_strip_flag = 0;
> +	} else {
> +		val64 = readq(&bar0->rx_pa_cfg);
> +		val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
> +		writeq(val64, &bar0->rx_pa_cfg);
> +		vlan_strip_flag = 1;
>  	}
> 
>  	/*
