From: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] Driver for the Microchip MCP251x SPI CAN
	controllers
Date: Mon, 2 Nov 2009 16:06:21 +0100
Message-ID: <cabda6420911020706r340ef073qea40527f09551a8a@mail.gmail.com>
References: <1256824214-21420-1-git-send-email-chripell@fsfe.org>
	<4AED5589.3090106@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4AED5589.3090106-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 1, 2009 at 10:31 AM, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org> wr=
ote:
> Hi Christian,
>

Hi,

> there are a few. In general, please check the usage of {} for if

sorry for missing this: I read your link below: I missed that rule on
first reading! And I tend to trust checkpatch.pl too much ;-)

> statements and check if "if (ret)" should be used instead of "if (ret <
> 0)" if 0 means success and !0 failure. I don't have a MCP251x hardware

ok, I misunderstood this to. Now I think it's ok.

I'm replying to this thread with v2 patch. I'm rebasing the
differences against SVN trunk too, but I'm waiting to send them until
this patch is accepted in net-next-2.6 since their are only of
cosmetic nature.

>
> Please use the subject prefix "can: Driver for the..."

ack

>> + =A0 =A0 depends on CAN && CAN_DEV && SPI
>
> You can drop the redundant dependency on "CAN".
>

ack, I just copied AT91 CAN which has this dependency

>> + * <chripell-LERDrqjqfvZg9hUCZPvPmw@public.gmane.org>
>
> Please add your "Copyright ...".
>

ack

>> +#include <linux/can/core.h>
>
> I don't think you need "can/core.h"?
>

I tried without but there are some dependencies in "can/dev.h" to some
netdev stuff that are broken if I omit it.

>> +#include <linux/if_arp.h>
>
> And that one either.
>

ack

>> +#define TXBCTRL(n) =A0((n * 0x10) + 0x30)
>
> Please put brackets around "n": (((n) * 0x10) + 0x30)
> Also the proper offset definition should be used.
>
> #define TXBCTRL(n) =A0(((n) * 0x10) + 0x30 + TXBCTRL_OFF)
>
> Here and in similar cases below.

ack

>> +#define RXBDAT_OFF =A06
>
> I was thinking to use structure(s) for the offsets (register layout)
> above, but fiddling with offsetof() does probably not make the code more
> readable.
>

Well I try avoid to unpacking bitfields with structs, I saw too many
problems witch cross-compiling when you have many different
architectures. I guess that using u8, u16 and similar should solve the
problems but I'm a bit like my cat: after she burned her whiskers, she
always stays away from kitchen stoves.

>> + =A0 =A0 if (ret < 0)
>
> if (ret) ?
>

ack

>> +static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *data,
>
> s/data/buf/ to avoid confusion with the CAN payload data.
>

ack

>> +static void mcp251x_hw_rx_frame(struct spi_device *spi, u8 *data,
>
> s/data/buf/, see above.
>
ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SET_BYTE(buf[RXBEID0_OFF], =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 0) |
>
> Please don't align arguments or variables.
>

ack, sorry for the nostalgia of ASCII art times

>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>
> Remove {}, please.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (buf[RXBSIDL_OFF] >> RXBSIDL_S=
HIFT);
>
> Please use {} here as well.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>
> return NETDEV_TX_OK; ?
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_=
LOOPBACK);
>
> Please use brackets here as well. See:
>
> http://lxr.linux.no/#linux+v2.6.31/Documentation/CodingStyle#L171
>

ack and thanks for the link

>> + =A0 =A0 /* Store original mode and set mode to config */
>
> Do you need that. The bit-timing can only be set when the device is
> stopped (down).
>

ack, you are right, no need for it because normal/loopback mode is
always set afterwards in _open

>> + =A0 =A0 if (ret < 0)
>
> if (ret) ?
>

ack

>> + =A0 =A0 if (ret < 0) {
>
> "if (ret)" ?
>

ack

>> + =A0 =A0 if (ret < 0) {
>
> "if (ret)" ?
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 disable_irq(spi->irq);
>
> free_irq? And what about the transeiver? The usual goto cleanup method
> would make sense here.
>

ack

>> + =A0 =A0 disable_irq(spi->irq);
>
> Why not freeing the irq already here?
>

ack, you are right

>> + =A0 =A0 flush_workqueue(priv->wq);
>> +
>> + =A0 =A0 mcp251x_write_reg(spi, TXBCTRL(0), 0);
>
> Hm, but you still need the interrupt!?

no, SPI interface and MCP251x interrupt are different

>> + =A0 =A0 close_candev(net);
>
> You should call close_candev early to cancel the buf-off recovery timer.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_set_normal_mode(spi);
>
> Please use {} here as well.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_hw_sleep(spi);
>
> Please use {} here as well.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_state =3D CAN_STATE_ERROR_=
ACTIVE;
>
> Please use {} here as well.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0"cannot allocate error skb\n");
>
> Please use {} here as well.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mcp251x_platform_data *pdat=
a)
>
> Add __devinit or, even better, put the code into mcp251x_can_probe?
>

ack, moved altogether

>> + =A0 =A0 priv->can.do_set_bittiming =A0 =A0 =A0=3D mcp251x_do_set_bitti=
ming;
>
> Don't align expressions. Use just *one* space before and after "=3D".
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_enable_dma =3D 0;
>
> Please use {} here as well.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->spi_=
tx_buf, priv->spi_tx_dma);
>
> Please use {} here as well.
>

ack

>> + =A0 =A0 =A0 =A0 =A0 =A0 priv->after_suspend =3D AFTER_SUSPEND_DOWN;
>
> Please use {} here as well.
>

ack

>
> Please use {} here as well and check for similar cases. I might not have
> spotted all.
>

ack, I searched for all else and checked

>> + =A0 =A0 .resume =A0 =A0 =A0 =A0 =3D mcp251x_can_resume,
>
> Use just *one* space before and after "=3D".
>

ack


Thanks for the review!

-- =

Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
