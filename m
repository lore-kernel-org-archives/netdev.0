From: Daniel Baluta <daniel.baluta-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH v2] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Mon, 13 Sep 2010 21:47:59 +0300
Message-ID: <AANLkTikLLmH-L_KZ8YOBgw6gxCpxPqSxr43pZF1Y8_-x@mail.gmail.com>
References: <4C8E1773.9090000@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "Andrew\"" <andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, "Wang Yong Y\"" <yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Tomoya MORINAGA <morinaga526-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org, arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, "Wang Qi\"" <qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C8E1773.9090000-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 13, 2010 at 3:22 PM, Masayuki Ohtak
<masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org> wrote:
> CAN driver of Topcliff PCH
>
> Topcliff PCH is the platform controller hub that is going to be used in
> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus.
> Topcliff PCH has CAN I/F. This driver enables CAN function.
>
> Signed-off-by: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
> +#define MAX_CAN_DEVICES =A0 =A0 =A0 =A0 =A0 =A0 =A01
Where is this used?

> +#define MAX_BITRATE =A0 =A0 =A0 =A0 =A0 =A00x3e8
> +#define NUM_NODES =A0 =A0 =A0 =A0 =A0 =A0 =A02000 =A0 =A0/* Maximum numb=
er of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0Software FIFO nodes. */
I think you don't need NUM_NODES.
> +/**
> + * struct pch_can_msg - CAN message structure
> + * @ide: =A0 =A0 =A0 Standard/extended msg
> + * @id: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A011 or 29 bit msg id
> + * @dlc: =A0 =A0 =A0 Size of data
> + * @data: =A0 =A0 =A0Message pay load
> + * @rtr: =A0 =A0 =A0 RTR message
> + */
> +struct pch_can_msg {
> + =A0 =A0 =A0 unsigned short ide;
> + =A0 =A0 =A0 unsigned int id;
> + =A0 =A0 =A0 unsigned short dlc;
> + =A0 =A0 =A0 unsigned char data[PCH_CAN_MSG_DATA_LEN];
> + =A0 =A0 =A0 unsigned short rtr;
> +};

I think you should use can_frame, and try to get rid of pch_can hardware
abstraction.


> +struct can_hw {
> + =A0 =A0 =A0 void __iomem *io_base;
> +};

Why do you need can_hw?

> +static int pch_can_get_rx_enable(struct can_hw *can, u32 buff_num, u32 *=
enable,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct n=
et_device *ndev)
Here ndev is used only for debugging purposes. It doesn't seem a natural
approach.

> +static irqreturn_t pch_can_handler(int irq, void *dev_id)
> +{
> + =A0 =A0 =A0 irqreturn_t retval =3D IRQ_NONE;
> + =A0 =A0 =A0 u32 int_stat;
> + =A0 =A0 =A0 struct pch_can_os *can_os;
> + =A0 =A0 =A0 struct net_device *ndev =3D (struct net_device *)dev_id;
> + =A0 =A0 =A0 struct pch_can_priv *priv =3D netdev_priv(ndev);
> + =A0 =A0 =A0 dev_dbg(&can_os->ndev->dev, "%s -> Invoked.\n", __func__);
> +
> + =A0 =A0 =A0 can_os =3D &priv->pch_can_os_p;
> + =A0 =A0 =A0 int_stat =3D pch_can_int_pending(can_os->can);

Where are the interrupt status bit(s) cleared?

> + =A0 =A0 =A0 dev_dbg(&can_os->ndev->dev,
> + =A0 =A0 =A0 =A0 "%s -> pch_can_int_pending returned value: %x\n", __fun=
c__, int_stat);
> +

As someone stated before I think you are trying to port an
old fashion CAN character device based driver.

Although, having the old source code, should be helpful
I think you should read the existing CAN drivers (drivers/net/can)
and start from scratch trying to follow the ideas implemented there.

I also have a character driver very similar with yours
(ICP CAN for EP80579) and I struggle for some time
to get a working version with Socket CAN interface.

I don't have any 'official' position towards Linux Socket CAN
so please consider my comments as being advisory.

thanks,
Daniel.
