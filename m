From: Manuel Schoelling <manuel.schoelling@gmx.de>
Subject: Re: [PATCH 1/3] net: vxge: Use time_is_before_jiffies() for time
 comparison
Date: Mon, 19 May 2014 18:53:42 +0200
Message-ID: <1400518422.4698.8.camel@schoellingm.dzne.de>
References: <1400518056-12089-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400518056-12089-1-git-send-email-manuel.schoelling@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, contrary to the subject of this mail, this is a single file
patch.
Patches 2-3 do not exist.

On Mo, 2014-05-19 at 18:47 +0200, Manuel Sch=C3=B6lling wrote:
> To be future-proof and for better readability the time comparisons ar=
e modified
> to use time_is_before_jiffies() instead of plain, error-prone math.
>=20
> Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
> ---
>  drivers/net/ethernet/neterion/vxge/vxge-main.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers=
/net/ethernet/neterion/vxge/vxge-main.c
> index d107bcb..79f42db 100644
> --- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
> +++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
> @@ -2122,7 +2122,7 @@ static int vxge_open_vpaths(struct vxgedev *vde=
v)
>  static void adaptive_coalesce_tx_interrupts(struct vxge_fifo *fifo)
>  {
>  	fifo->interrupt_count++;
> -	if (jiffies > fifo->jiffies + HZ / 100) {
> +	if (time_is_before_jiffies(fifo->jiffies + HZ / 100)) {
>  		struct __vxge_hw_fifo *hw_fifo =3D fifo->handle;
> =20
>  		fifo->jiffies =3D jiffies;
> @@ -2150,7 +2150,7 @@ static void adaptive_coalesce_tx_interrupts(str=
uct vxge_fifo *fifo)
>  static void adaptive_coalesce_rx_interrupts(struct vxge_ring *ring)
>  {
>  	ring->interrupt_count++;
> -	if (jiffies > ring->jiffies + HZ / 100) {
> +	if (time_is_before_jiffies(ring->jiffies + HZ / 100)) {
>  		struct __vxge_hw_ring *hw_ring =3D ring->handle;
> =20
>  		ring->jiffies =3D jiffies;
