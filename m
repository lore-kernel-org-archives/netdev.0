From: Wu Zhangjin <wuzhangjin@gmail.com>
Subject: Re: [PATCH V2 2/4] MIPS: Add board support for Loongson1B
Date: Sat, 22 Oct 2011 01:33:29 +0800
Message-ID: <CAD+V5YKBkW52_md9rBeVZ1RXq2FGEXt=Ergsw+z8txMreZdNsA@mail.gmail.com>
References: <1319192888-21465-1-git-send-email-keguang.zhang@gmail.com>
	<1319192888-21465-2-git-send-email-keguang.zhang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	ralf@linux-mips.org, r0bertz@gentoo.org, netdev@vger.kernel.org
To: keguang.zhang@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319192888-21465-2-git-send-email-keguang.zhang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 21, 2011 at 6:28 PM,  <keguang.zhang@gmail.com> wrote:
> From: Kelvin Cheung <keguang.zhang@gmail.com>
>
> This patch adds basic platform support for Loongson1B
> including serial port, ethernet, and interrupt handler.
>
> Loongson1B UART is compatible with NS16550A.
> Loongson1B GMAC is built around Synopsys IP Core.
>

Perhaps you'd better split out the GMAC support to its own patch and
send it to the net/ maintainer and the authors of the original files.

> diff --git a/drivers/net/stmmac/descs.h b/drivers/net/stmmac/descs.h
> index 63a03e2..4db27d0 100644
> --- a/drivers/net/stmmac/descs.h
> +++ b/drivers/net/stmmac/descs.h
> @@ -53,6 +53,38 @@ struct dma_desc {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 reserved3:5;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 disable_ic:1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} rx;
> +#ifdef CONFIG_MACH_LOONGSON1
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* RDES0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 payload_csum_error:=
1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 crc_error:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 dribbling:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 error_gmii:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 receive_watchdog:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 frame_type:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 late_collision:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 ipc_csum_error:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 last_descriptor:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 first_descriptor:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 vlan_tag:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 overflow_error:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 length_error:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 sa_filter_fail:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 descriptor_error:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 error_summary:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 frame_length:14;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 da_filter_fail:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 own:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* RDES1 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 buffer1_size:11;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 buffer2_size:11;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 reserved1:2;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 second_address_chai=
ned:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 end_ring:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 reserved2:5;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 disable_ic:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } erx; =A0 =A0 =A0 =A0 =A0/* -- enhance=
d -- */
> +#else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* RDES0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 payload_csum_error=
:1;
> @@ -83,6 +115,7 @@ struct dma_desc {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 reserved2:2;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 disable_ic:1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} erx; =A0 =A0 =A0 =A0 =A0/* -- enhanc=
ed -- */
> +#endif
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Transmit descriptor */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct {
> @@ -113,6 +146,40 @@ struct dma_desc {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 last_segment:1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 interrupt:1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} tx;
> +#ifdef CONFIG_MACH_LOONGSON1
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TDES0 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 deferred:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 underflow_error:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 excessive_deferral:=
1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 collision_count:4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 vlan_frame:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 excessive_collision=
s:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 late_collision:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 no_carrier:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 loss_carrier:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 payload_error:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 frame_flushed:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 jabber_timeout:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 error_summary:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 ip_header_error:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 time_stamp_status:1=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 reserved1:13;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 own:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TDES1 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 buffer1_size:11;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 buffer2_size:11;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 time_stamp_enable:1=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 disable_padding:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 second_address_chai=
ned:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 end_ring:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 crc_disable:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 checksum_insertion:=
2;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 first_segment:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 last_segment:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u32 interrupt:1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } etx; =A0 =A0 =A0 =A0 =A0/* -- enhance=
d -- */
> +#else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* TDES0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 deferred:1;
> @@ -148,6 +215,7 @@ struct dma_desc {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 buffer2_size:13;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u32 reserved4:3;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} etx; =A0 =A0 =A0 =A0 =A0/* -- enhanc=
ed -- */
> +#endif
> =A0 =A0 =A0 =A0} des01;
> =A0 =A0 =A0 =A0unsigned int des2;
> =A0 =A0 =A0 =A0unsigned int des3;


If the difference is very much, perhaps a new dma_desc struct can be
defined instead.

> diff --git a/drivers/net/stmmac/enh_desc.c b/drivers/net/stmmac/enh_d=
esc.c
> index e5dfb6a..3b5e4f1 100644
> --- a/drivers/net/stmmac/enh_desc.c
> +++ b/drivers/net/stmmac/enh_desc.c
> @@ -108,6 +108,7 @@ static int enh_desc_get_tx_len(struct dma_desc *p=
)
> =A0static int enh_desc_coe_rdes0(int ipc_err, int type, int payload_e=
rr)
> =A0{
> =A0 =A0 =A0 =A0int ret =3D good_frame;
> +#ifndef CONFIG_MACH_LOONGSON1
> =A0 =A0 =A0 =A0u32 status =3D (type << 2 | ipc_err << 1 | payload_err=
) & 0x7;
>
> =A0 =A0 =A0 =A0/* bits 5 7 0 | Frame status
> @@ -145,6 +146,7 @@ static int enh_desc_coe_rdes0(int ipc_err, int ty=
pe, int payload_err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CHIP_DBG(KERN_ERR "RX Des0 status: No =
IPv4, IPv6 frame.\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D discard_frame;
> =A0 =A0 =A0 =A0}
> +#endif
> =A0 =A0 =A0 =A0return ret;
> =A0}

>
> @@ -232,9 +234,17 @@ static void enh_desc_init_rx_desc(struct dma_des=
c *p, unsigned int ring_size,
> =A0 =A0 =A0 =A0int i;
> =A0 =A0 =A0 =A0for (i =3D 0; i < ring_size; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->des01.erx.own =3D 1;
> +#ifdef CONFIG_MACH_LOONGSON1
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->des01.erx.buffer1_size =3D BUF_SIZE_=
2KiB - 1;
> +#else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->des01.erx.buffer1_size =3D BUF_SIZE=
_8KiB - 1;
> +#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* To support jumbo frames */
> +#ifdef CONFIG_MACH_LOONGSON1
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->des01.erx.buffer2_size =3D BUF_SIZE_=
2KiB - 1;
> +#else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->des01.erx.buffer2_size =3D BUF_SIZE=
_8KiB - 1;
> +#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (i =3D=3D ring_size - 1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->des01.erx.end_ring =
=3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (disable_rx_ic)
> @@ -292,9 +302,15 @@ static void enh_desc_prepare_tx_desc(struct dma_=
desc *p, int is_fs, int len,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 int csum_flag)
> =A0{
> =A0 =A0 =A0 =A0p->des01.etx.first_segment =3D is_fs;
> +#ifdef CONFIG_MACH_LOONGSON1
> + =A0 =A0 =A0 if (unlikely(len > BUF_SIZE_2KiB)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->des01.etx.buffer1_size =3D BUF_SIZE_=
2KiB - 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 p->des01.etx.buffer2_size =3D len - BUF=
_SIZE_2KiB + 1;
> +#else
> =A0 =A0 =A0 =A0if (unlikely(len > BUF_SIZE_4KiB)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->des01.etx.buffer1_size =3D BUF_SIZE=
_4KiB;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->des01.etx.buffer2_size =3D len - BU=
=46_SIZE_4KiB;
> +#endif
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0p->des01.etx.buffer1_size =3D len;
> =A0 =A0 =A0 =A0}

Is it possible to add two new macros RX_BUF_SIZE and TX_BUF_SIZE to .h
instead? which may reduce code duplication.

Regards,
Wu Zhangjin

> --
> 1.7.1
>
>
