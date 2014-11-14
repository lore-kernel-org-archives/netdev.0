From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1 net-next] net: dsa: replace count*size kmalloc by
 kmalloc_array
Date: Fri, 14 Nov 2014 20:02:38 +0100 (CET)
Message-ID: <2104595537.56209.1415991758726.open-xchange@webmail.nmp.skynet.be>
References: <1415990202-28673-1-git-send-email-fabf@skynet.be> <1415990835.5912.20.camel@perches.com>
Reply-To: Fabian Frederick <fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415990835.5912.20.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> On 14 November 2014 at 19:47 Joe Perches <joe@perches.com> wrote:
>
>
> On Fri, 2014-11-14 at 19:36 +0100, Fabian Frederick wrote:
> > kmalloc_array manages count*sizeof overflow.
>
> Fundamentally correct, but is this necessary or useful?
> sizeof(s8) isn't often going to be anything other than 1.
Absolutely, I thought it was a struct :)

There must be a reason for so many cases though ...

Regards,
=46abian

>
> Would the kernel even work without that assumption?
>
>
> > diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> []
> > @@ -526,7 +526,8 @@ static int dsa_of_setup_routing_table(struct
> > dsa_platform_data *pd,
> >=C2=A0
> >=C2=A0 =C2=A0 =C2=A0/* First time routing table allocation */
> >=C2=A0 =C2=A0 =C2=A0if (!cd->rtable) {
> > -=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cd->rtable =3D kmalloc(pd=
->nr_chips * sizeof(s8), GFP_KERNEL);
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cd->rtable =3D kmalloc_ar=
ray(pd->nr_chips, sizeof(s8),
> > +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 GFP_=
KERNEL);
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!cd->rtable)
> >=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0return -ENOMEM;
> >=C2=A0
>
> Maybe all of these could be simplified
>
> $ git grep -E "\*\s*sizeof\s*\(\s*[us]8\s*\)"
> arch/arm/common/edma.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0(edma_cc->num_tc +
> 1) * sizeof(s8),
> drivers/acpi/utils.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(element=
->buffer.length *
> sizeof(u8));
> drivers/acpi/utils.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0tail +=3D element->buf=
fer.length
> * sizeof(u8);
> drivers/char/tpm/tpm_i2c_stm_st33.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 kmall=
oc(TPM_BUFSIZE * sizeof(u8),
> GFP_KERNEL);
> drivers/char/tpm/tpm_i2c_stm_st33.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 kmall=
oc(TPM_BUFSIZE * sizeof(u8),
> GFP_KERNEL);
> drivers/gpu/drm/r128/r128_state.c:=C2=A0 =C2=A0 =C2=A0 mask_size =3D =
depth->n * sizeof(u8);
> drivers/gpu/drm/r128/r128_state.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 mask_size =3D depth->n *
> sizeof(u8);
> drivers/iio/common/st_sensors/st_sensors_spi.c: memcpy(data, tb->rx_b=
uf,
> len*sizeof(u8));
> drivers/infiniband/hw/amso1100/c2_mq.h: u8 pad[64 - sizeof(u16) - 2 *
> sizeof(u8) - sizeof(u32) - sizeof(u16)];
> drivers/input/tablet/aiptek.c:=C2=A0 const int sizeof_buf =3D 3 * siz=
eof(u8);
> drivers/input/tablet/aiptek.c:=C2=A0 const int sizeof_buf =3D 3 * siz=
eof(u8);
> drivers/md/dm-crypt.c:=C2=A0 memset(&cc->key, 0, cc->key_size * sizeo=
f(u8));
> drivers/md/dm-crypt.c:=C2=A0 cc =3D kzalloc(sizeof(*cc) + key_size * =
sizeof(u8),
> GFP_KERNEL);
> drivers/media/dvb-frontends/dib7000p.c: tx =3D kzalloc(2*sizeof(u8),
> GFP_KERNEL);
> drivers/media/dvb-frontends/dib7000p.c: rx =3D kzalloc(2*sizeof(u8),
> GFP_KERNEL);
> drivers/media/dvb-frontends/dib8000.c:=C2=A0 client.i2c_write_buffer =
=3D kzalloc(4 *
> sizeof(u8), GFP_KERNEL);
> drivers/media/dvb-frontends/dib8000.c:=C2=A0 client.i2c_read_buffer =3D=
 kzalloc(4 *
> sizeof(u8), GFP_KERNEL);
> drivers/media/dvb-frontends/dib9000.c:=C2=A0 client.i2c_write_buffer =
=3D kzalloc(4 *
> sizeof(u8), GFP_KERNEL);
> drivers/media/dvb-frontends/dib9000.c:=C2=A0 client.i2c_read_buffer =3D=
 kzalloc(4 *
> sizeof(u8), GFP_KERNEL);
> drivers/media/pci/ttpci/av7110_ipack.c: if (!(p->buf =3D
> vmalloc(size*sizeof(u8)))) {
> drivers/mtd/inftlmount.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->nb=
_blocks *
> sizeof(u8));
> drivers/net/wireless/ath/ath10k/htt.h:=C2=A0 =C2=A0*=C2=A0 b) num_cha=
rs * sizeof(u8) aligned
> to 4bytes */
> drivers/net/wireless/b43/ppr.c: BUILD_BUG_ON(sizeof(struct b43_ppr) !=
=3D
> B43_PPR_RATES_NUM * sizeof(u8));
> drivers/net/wireless/iwlwifi/pcie/trans.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0
> =C2=A0trans_pcie->n_no_reclaim_cmds * sizeof(u8));
> drivers/net/wireless/rtlwifi/efuse.c:=C2=A0 =C2=A0memset(data, 0xff, =
PGPKT_DATA_SIZE *
> sizeof(u8));
> drivers/net/wireless/rtlwifi/efuse.c:=C2=A0 =C2=A0memset(tmpdata, 0xf=
f, PGPKT_DATA_SIZE
> * sizeof(u8));
> drivers/net/wireless/rtlwifi/efuse.c:=C2=A0 =C2=A0u8 originaldata[8 *=
 sizeof(u8)];
> drivers/net/wireless/rtlwifi/efuse.c:=C2=A0 =C2=A0u8 originaldata[8 *=
 sizeof(u8)];
> drivers/net/wireless/rtlwifi/efuse.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0memset(originaldata, 0xff,=C2=A0 8
> * sizeof(u8));
> drivers/net/wireless/rtlwifi/efuse.c:=C2=A0 =C2=A0memset(target_pkt.d=
ata, 0xFF,=C2=A0 8 *
> sizeof(u8));
> drivers/power/ds2781_battery.c: ret =3D w1_ds2781_read(dev_info, val,
> DS2781_VOLT_MSB, 2 * sizeof(u8));
> drivers/power/ds2781_battery.c: ret =3D w1_ds2781_read(dev_info, val,
> DS2781_TEMP_MSB, 2 * sizeof(u8));
> drivers/rtc/rtc-pcf2123.c:=C2=A0 =C2=A0 =C2=A0 ret =3D spi_write(spi,=
 txbuf, 2 * sizeof(u8));
> drivers/rtc/rtc-pcf2123.c:=C2=A0 =C2=A0 =C2=A0 ret =3D spi_write(spi,=
 txbuf, 2 * sizeof(u8));
> drivers/rtc/rtc-pcf2123.c:=C2=A0 =C2=A0 =C2=A0 ret =3D spi_write_then=
_read(spi, txbuf, 1 *
> sizeof(u8),
> drivers/rtc/rtc-pcf2123.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 rxbuf, 2 *
> sizeof(u8));
> drivers/thermal/x86_pkg_temp_thermal.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(max_phy_id+1) *
> sizeof(u8), GFP_ATOMIC);
> fs/compat_ioctl.c:=C2=A0 =C2=A0 =C2=A0 if (__copy_in_user(&tdata->rea=
d_write,
> &udata->read_write, 2 * sizeof(u8)))
> net/dsa/dsa.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cd->rtable =3D kmall=
oc(pd->nr_chips * sizeof(s8),
> GFP_KERNEL);
> net/dsa/dsa.c:=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memset(cd->rtable, -=
1, pd->nr_chips * sizeof(s8));
>
>
