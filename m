From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH v2 46/46] net: mark drivers that drop packets from
 rx queue head under memory pressure
Date: Mon, 11 Jul 2011 09:47:08 +0300
Message-ID: <1310366828.22731.1.camel@lb-tlvb-eilong.il.broadcom.com>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hartley Sweeten" <hsweeten@visionengravers.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"Guo-Fu Tseng" <cooldavid@cooldavid.org>,
	"Realtek linux nic maintainers" <nic_swsd@realtek.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Jon Mason" <jdmason@kudzu.us>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3661 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756726Ab1GKGrg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 02:47:36 -0400
In-Reply-To: <c84a04a957128ae664f4a80da23fad4b9f71a85f.1310339689.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-07-10 at 17:52 -0700, Micha=C5=82 Miros=C5=82aw wrote:
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
> ---

> diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_=
cmn.c
> index 4f9164c..a6da01a 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> @@ -673,6 +673,9 @@ int bnx2x_rx_int(struct bnx2x_fastpath *fp, int b=
udget)
>  				goto reuse_rx;
>  			}
> =20
> +#warning drops packets from rx queue head on memory pressure
> +#warning (like dev_skb_finish_rx_dma_refill() users)
> +

We have the dropless_fc module parameter that can be configured if the
user prefers pausing on host memory pressure - the problem with that
feature is that it is enough that one of the ring runs out of memory an=
d
the entire port is stopped. When running with 16 rings, this can lead t=
o
serious throughput degradation - this is why it is kept as a user
configurable option.

>  			/* Since we don't have a jumbo ring
>  			 * copy small packets if mtu > 1500
>  			 */



