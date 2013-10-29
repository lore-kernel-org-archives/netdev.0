From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] can: c_can: Speed up rx_poll function
Date: Tue, 29 Oct 2013 01:31:01 -0700
Message-ID: <1383035461.2713.1.camel@joe-AO722>
References: <1383035267-19604-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: Markus Pargmann <mpa@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1383035267-19604-1-git-send-email-mpa@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-10-29 at 09:27 +0100, Markus Pargmann wrote:
> This patch speeds up the rx_poll function by reducing the number of
> register reads.
[]
> The third change is to replace the for-loop by a find_next_bit loop.

You need to update the commit message.

> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
[]
> @@ -798,17 +798,19 @@ static int c_can_do_rx_poll(struct net_device *dev, int quota)
[]
> +	while (quota > 0 && (val = priv->read_reg(priv, C_CAN_INTPND1_REG))) {
> +		while ((msg_obj = ffs(val)) && quota > 0) {
> +			val &= ~BIT(msg_obj - 1);



