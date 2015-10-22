From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH 2/2] can: xilinx: fix bug in bus error handling
Date: Thu, 22 Oct 2015 09:33:15 -0700
Message-ID: <20151022163315.GI5257@xsjsorenbubuntu>
References: <1445489163-11045-1-git-send-email-appanad@xilinx.com>
 <1445489163-11045-2-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <anirudh@xilinx.com>, <wg@grandegger.com>, <mkl@pengutronix.de>,
	<michal.simek@xilinx.com>, <appanad@xilinx.com>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445489163-11045-2-git-send-email-appanad@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-10-22 at 10:16AM +0530, Kedareswara rao Appana wrote:
> Simply resetting the peripheral on bus off condition is not enough,
> Because we also need to re-initialize the whole device.
> This patch fixes this issue.
>=20
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> ---
>  drivers/net/can/xilinx_can.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/can/xilinx_can.c b/drivers/net/can/xilinx_ca=
n.c
> index 055d6f3..9aeb85f 100644
> --- a/drivers/net/can/xilinx_can.c
> +++ b/drivers/net/can/xilinx_can.c
> @@ -529,6 +529,8 @@ static int xcan_rx(struct net_device *ndev)
>  	return 1;
>  }
> =20
> +static void xcan_chip_stop(struct net_device *ndev);

Isn't it possible to move the function and avoid the forward
declaration?

	S=C3=B6ren
