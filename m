From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Wed, 19 Jan 2011 17:40:07 +0800
Message-ID: <AANLkTi=nJxwR89CF3i0+L6+yM4Bg_PN8PQByTAHP2nPM@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com> <1295284788.21277.65.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, dilinger@queued.net
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295284788.21277.65.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Joe,

On Tue, Jan 18, 2011 at 1:19 AM, Joe Perches <joe@perches.com> wrote:
> On Mon, 2011-01-17 at 17:21 +0800, Po-Yu Chuang wrote:
>
>> + * priveate data
>
> private

=46ixed.

>> +static void ftmac100_enable_all_int(struct ftmac100 *priv)
>> +{
>> + =C2=A0 =C2=A0 unsigned int imr;
>> +
>> + =C2=A0 =C2=A0 imr =3D FTMAC100_INT_RPKT_FINISH | FTMAC100_INT_NORX=
BUF
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| FTMAC100_INT_XPKT_OK | FTMAC10=
0_INT_XPKT_LOST
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| FTMAC100_INT_RPKT_LOST | FTMAC=
100_INT_AHB_ERR
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| FTMAC100_INT_PHYSTS_CHG;
>
> This could be a #define.

OK, done.

>> + =C2=A0 =C2=A0 maccr =3D FTMAC100_MACCR_XMT_EN |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_MACCR_RCV_EN |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_MACCR_XDMA_EN |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_MACCR_RDMA_EN |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_MACCR_CRC_APD |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_MACCR_FULLDUP |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_MACCR_RX_RUNT |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_MACCR_RX_BROADP=
KT;
>
> Here too.

OK, done.

>> +static int ftmac100_rx_packet_error(struct ftmac100 *priv,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct ftmac100_rxdes *r=
xdes)
> []
>> + =C2=A0 =C2=A0 if (unlikely(ftmac100_rxdes_frame_too_long(rxdes))) =
{
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (net_ratelimit())
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 netdev_info(netdev, "rx frame too long\n");
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netdev->stats.rx_length_=
errors++;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 error =3D 1;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 if (unlikely(ftmac100_rxdes_runt(rxdes))) {
>
> else if ?

OK, fixed.

>> +static int ftmac100_rx_packet(struct ftmac100 *priv, int *processed=
)
>> +{
>> + =C2=A0 =C2=A0 struct net_device *netdev =3D priv->netdev;
>> + =C2=A0 =C2=A0 struct ftmac100_rxdes *rxdes;
>> + =C2=A0 =C2=A0 struct sk_buff *skb;
>> + =C2=A0 =C2=A0 int length;
>> + =C2=A0 =C2=A0 int copied =3D 0;
>> + =C2=A0 =C2=A0 int done =3D 0;
>
> You could use bool/true/false here for copied and done
> and all the other uses of an int for a logical bool.

OK, fixed.

>> +static void ftmac100_txdes_set_dma_own(struct ftmac100_txdes *txdes=
)
>> +{
>> + =C2=A0 =C2=A0 /*
>> + =C2=A0 =C2=A0 =C2=A0* Make sure dma own bit will not be set before=
 any other
>> + =C2=A0 =C2=A0 =C2=A0* descriptor fiels.
>
> field/fields

=46ixed.

>> +static int ftmac100_mdio_read(struct net_device *netdev, int phy_id=
, int reg)
>> +{
>> + =C2=A0 =C2=A0 struct ftmac100 *priv =3D netdev_priv(netdev);
>> + =C2=A0 =C2=A0 int phycr;
>> + =C2=A0 =C2=A0 int i;
>> +
>> + =C2=A0 =C2=A0 phycr =3D FTMAC100_PHYCR_PHYAD(phy_id) |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_PHYCR_REGAD(reg=
) |
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 FTMAC100_PHYCR_MIIRD;
>> +
>> + =C2=A0 =C2=A0 iowrite32(phycr, priv->base + FTMAC100_OFFSET_PHYCR)=
;
>> + =C2=A0 =C2=A0 for (i =3D 0; i < 10; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 phycr =3D ioread32(priv-=
>base + FTMAC100_OFFSET_PHYCR);
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if ((phycr & FTMAC100_PH=
YCR_MIIRD) =3D=3D 0)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 return phycr & FTMAC100_PHYCR_MIIRDATA;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 usleep_range(100, 1000);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 netdev_err(netdev, "mdio read timed out\n");
>> + =C2=A0 =C2=A0 return 0xffff;
>
> 0xffff is a rather odd return, perhaps a #define?

After a little digging in drivers/net/mii.c, it seems that mii lib does=
 not
check return value if it is error. So I guess I should return 0 if erro=
r.

>> +/******************************************************************=
************
>> + * initialization / finalization
>> + ******************************************************************=
***********/
>> +static int __init ftmac100_init(void)
>> +{
>> + =C2=A0 =C2=A0 printk(KERN_INFO "Loading " DRV_NAME ": version " DR=
V_VERSION " ...\n");
>
> You could use
> #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> before any #include and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pr_info("Loading version " DRV_VERSION " .=
=2E.\n");

OK

> One last comment on split long line indentation style
> and long function declarations.
>
> There's no required style so you can use what you are
> most comfortable doing.
>
> Most of drivers/net uses an alignment to open parenthesis
> using maximal tabs and minimal necessary spaces instead of
> an extra tabstop.
>
> Like:
>
> static int some_long_function(type var1, type var2...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0type varN)
> and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0some_long_function(var1, var2, ...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 varN);
>
> not
> static int some_long_function(type var1, type var2...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0type varN)
> and
> =C2=A0 =C2=A0 =C2=A0 =C2=A0some_long_function(var1, var2, ...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0varN);

Well, TBH, I don't like this style because if I changed the
function name, the indentation might need to be adjusted.

Even worse, I got an infeasible case :-(

static struct ftmac100_rxdes *ftmac100_rx_locate_first_segment(
							       struct ftmac100 *priv)

I know my function names are quite long, but I like them to be descript=
ive.
Do you really insist on it?

Thanks,
Po-Yu Chuang
