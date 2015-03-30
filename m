From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH net-next V3 06/23] ptp: bnx2x: convert to the 64 bit
 get/set time methods.
Date: Mon, 30 Mar 2015 21:13:19 +0000
Message-ID: <0EA5B226BC5C7B45A71BF612AA8A019E01946EFE0B@AVMB1.qlogic.org>
References: <cover.1427662906.git.richardcochran@gmail.com>
 <df76e4e50c144a6861c698378c34e52b35e1fbaf.1427662907.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	"David Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	"Giuseppe Cavallaro" <peppe.cavallaro@st.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	"Prashant Sreedharan" <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarfl
To: Richard Cochran <richardcochran@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <df76e4e50c144a6861c698378c34e52b35e1fbaf.1427662907.git.richardcochran@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: linux-kernel-owner@vger.kernel.org [mailto:linux-kernel-
> owner@vger.kernel.org] On Behalf Of Richard Cochran
> Sent: Sunday, March 29, 2015 2:12 PM
> To: netdev
> Cc: linux-kernel; Amir Vadai; Ariel Elior; Arnd Bergmann; Baolin
> Wang; Ben Hutchings; Bruce Allan; Carolyn Wyborny; Chris
> Metcalf; David Miller; Frank Li; Giuseppe Cavallaro; Jacob Keller;
> Jeff Kirsher; John Stultz; Luwei Zhou; Matthew Vick; Michael
> Chan; Prashant Sreedharan; Rayagond K; Shradha Shah;
> Solarflare linux maintainers; Sonic Zhang; Stefan S=F8rensen;
> Thomas Gleixner; Tom Lendacky
> Subject: [PATCH net-next V3 06/23] ptp: bnx2x: convert to the 64
> bit get/set time methods.
>=20
> This driver's clock is implemented using a timecounter, and so
> with this patch the driver is ready for the year 2038.
>=20
> Compile tested only.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    8
> ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> index 9677431..765667c 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
> @@ -13278,7 +13278,7 @@ static int bnx2x_ptp_adjtime(struct
> ptp_clock_info *ptp, s64 delta)
>  	return 0;
>  }
>=20
> -static int bnx2x_ptp_gettime(struct ptp_clock_info *ptp, struct
> timespec *ts)
> +static int bnx2x_ptp_gettime(struct ptp_clock_info *ptp, struct
> +timespec64 *ts)
>  {
>  	struct bnx2x *bp =3D container_of(ptp, struct bnx2x,
> ptp_clock_info);
>  	u64 ns;
> @@ -13295,7 +13295,7 @@ static int bnx2x_ptp_gettime(struct
> ptp_clock_info *ptp, struct timespec *ts)  }
>=20
>  static int bnx2x_ptp_settime(struct ptp_clock_info *ptp,
> -			     const struct timespec *ts)
> +			     const struct timespec64 *ts)
>  {
>  	struct bnx2x *bp =3D container_of(ptp, struct bnx2x,
> ptp_clock_info);
>  	u64 ns;
> @@ -13333,8 +13333,8 @@ static void
> bnx2x_register_phc(struct bnx2x *bp)
>  	bp->ptp_clock_info.pps =3D 0;
>  	bp->ptp_clock_info.adjfreq =3D bnx2x_ptp_adjfreq;
>  	bp->ptp_clock_info.adjtime =3D bnx2x_ptp_adjtime;
> -	bp->ptp_clock_info.gettime =3D bnx2x_ptp_gettime;
> -	bp->ptp_clock_info.settime =3D bnx2x_ptp_settime;
> +	bp->ptp_clock_info.gettime64 =3D bnx2x_ptp_gettime;
> +	bp->ptp_clock_info.settime64 =3D bnx2x_ptp_settime;
>  	bp->ptp_clock_info.enable =3D bnx2x_ptp_enable;

Acked-by: Sony Chacko <sony.chacko@qlogic.com>

Thanks,
Sony
