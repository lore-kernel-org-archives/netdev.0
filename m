From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: can: usb: gs_usb: Fix buffer on stack
Date: Sat, 22 Apr 2017 14:30:25 -0300
Message-ID: <CAOMZO5DLdR00FY01r2z=RvSrn4vNEZ+Z3OS0KWB95DGt=3fh2w@mail.gmail.com>
References: <20170422165626.10534-1-maksim.salau@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Maximilian Schneider <max@schneidersoft.net>,
        Hubert Denkmair <hubert@denkmair.de>,
        Wolfram Sang <wsa-dev@sang-engineering.com>,
        Ethan Zonca <e@ethanzonca.com>, linux-can@vger.kernel.org,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Maksim Salau <maksim.salau@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170422165626.10534-1-maksim.salau@gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 22, 2017 at 1:56 PM, Maksim Salau <maksim.salau@gmail.com> wrote:
> Allocate buffer on HEAP instead of STACK for a local structure
> that is to be sent using usb_control_msg().
>
> Signed-off-by: Maksim Salau <maksim.salau@gmail.com>
> ---
>  drivers/net/can/usb/gs_usb.c | 17 ++++++++++++-----
>  1 file changed, 12 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
> index a0dabd4..98f972a 100644
> --- a/drivers/net/can/usb/gs_usb.c
> +++ b/drivers/net/can/usb/gs_usb.c
> @@ -740,13 +740,18 @@ static const struct net_device_ops gs_usb_netdev_ops = {
>  static int gs_usb_set_identify(struct net_device *netdev, bool do_identify)
>  {
>         struct gs_can *dev = netdev_priv(netdev);
> -       struct gs_identify_mode imode;
> +       struct gs_identify_mode *imode = NULL;

No need to assign imode to NULL here.
