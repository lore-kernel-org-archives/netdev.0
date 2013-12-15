From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH] drivers: ptp: Include new header file in ptp_pch.c
Date: Sun, 15 Dec 2013 13:01:29 -0800
Message-ID: <20131215210129.GG9804@leaf>
References: <1387140255-11797-1-git-send-email-rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Darren Hart <dvhart@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Veaceslav Falico <vfalico@redhat.com>, netdev@vger.kernel.org
To: Rashika Kheria <rashika.kheria@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1387140255-11797-1-git-send-email-rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 02:14:15AM +0530, Rashika Kheria wrote:
> Create a new header file include/linux/ptp_pch.h which contains
> prototype declaration of functions pch_ch_control_read(),
> pch_ch_control_write(), pch_ch_event_read(), pch_ch_event_write(),
> pch_src_uuid_lo_read(), pch_src_uuid_hi_read(), pch_rx_snap_read(),
> pch_tx_snap_read() and pch_set_station_address().
>=20
> Include the new header file in drivers/ptp/ptp_pch.c and
> drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c because they
> use these functions. Remove these functions prototypes from header
> file drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h.
>=20
> This eliminates the following warnings in ptp_pch.c:
>=20
> drivers/ptp/ptp_pch.c:194:5: warning: no previous prototype for =E2=80=
=98pch_ch_control_read=E2=80=99 [-Wmissing-prototypes]
> drivers/ptp/ptp_pch.c:205:6: warning: no previous prototype for =E2=80=
=98pch_ch_control_write=E2=80=99 [-Wmissing-prototypes]
> drivers/ptp/ptp_pch.c:213:5: warning: no previous prototype for =E2=80=
=98pch_ch_event_read=E2=80=99 [-Wmissing-prototypes]
> drivers/ptp/ptp_pch.c:224:6: warning: no previous prototype for =E2=80=
=98pch_ch_event_write=E2=80=99 [-Wmissing-prototypes]
> drivers/ptp/ptp_pch.c:232:5: warning: no previous prototype for =E2=80=
=98pch_src_uuid_lo_read=E2=80=99 [-Wmissing-prototypes]
> drivers/ptp/ptp_pch.c:243:5: warning: no previous prototype for =E2=80=
=98pch_src_uuid_hi_read=E2=80=99 [-Wmissing-prototypes]
> drivers/ptp/ptp_pch.c:254:5: warning: no previous prototype for =E2=80=
=98pch_rx_snap_read=E2=80=99 [-Wmissing-prototypes]
> drivers/ptp/ptp_pch.c:271:5: warning: no previous prototype for =E2=80=
=98pch_tx_snap_read=E2=80=99 [-Wmissing-prototypes]
> drivers/ptp/ptp_pch.c:312:5: warning: no previous prototype for =E2=80=
=98pch_set_station_address=E2=80=99 [-Wmissing-prototypes]
>=20
> Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>

Reviewed-by: Josh Triplett <josh@joshtriplett.org>

>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    9 ---------
>  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    1 +
>  drivers/ptp/ptp_pch.c                              |    1 +
>  include/linux/ptp_pch.h                            |   16 ++++++++++=
++++++
>  4 files changed, 18 insertions(+), 9 deletions(-)
>  create mode 100644 include/linux/ptp_pch.h
>=20
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/driver=
s/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> index 2a900307..79533c8 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
> @@ -666,15 +666,6 @@ void pch_gbe_free_tx_resources(struct pch_gbe_ad=
apter *adapter,
>  void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
>  			       struct pch_gbe_rx_ring *rx_ring);
>  void pch_gbe_update_stats(struct pch_gbe_adapter *adapter);
> -u32 pch_ch_control_read(struct pci_dev *pdev);
> -void pch_ch_control_write(struct pci_dev *pdev, u32 val);
> -u32 pch_ch_event_read(struct pci_dev *pdev);
> -void pch_ch_event_write(struct pci_dev *pdev, u32 val);
> -u32 pch_src_uuid_lo_read(struct pci_dev *pdev);
> -u32 pch_src_uuid_hi_read(struct pci_dev *pdev);
> -u64 pch_rx_snap_read(struct pci_dev *pdev);
> -u64 pch_tx_snap_read(struct pci_dev *pdev);
> -int pch_set_station_address(u8 *addr, struct pci_dev *pdev);
> =20
>  /* pch_gbe_param.c */
>  void pch_gbe_check_options(struct pch_gbe_adapter *adapter);
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/d=
rivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 27ffe0e..03e2c14 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -24,6 +24,7 @@
>  #include <linux/net_tstamp.h>
>  #include <linux/ptp_classify.h>
>  #include <linux/gpio.h>
> +#include <linux/ptp_pch.h>
> =20
>  #define DRV_VERSION     "1.01"
>  const char pch_driver_version[] =3D DRV_VERSION;
> diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
> index 71a2559..ec5cf7d 100644
> --- a/drivers/ptp/ptp_pch.c
> +++ b/drivers/ptp/ptp_pch.c
> @@ -20,6 +20,7 @@
>   * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1=
307, USA.
>   */
> =20
> +#include <linux/ptp_pch.h>
>  #include <linux/device.h>
>  #include <linux/err.h>
>  #include <linux/init.h>
> diff --git a/include/linux/ptp_pch.h b/include/linux/ptp_pch.h
> new file mode 100644
> index 0000000..bd23d53
> --- /dev/null
> +++ b/include/linux/ptp_pch.h
> @@ -0,0 +1,16 @@
> +#include <linux/types.h>
> +#include <linux/pci.h>
> +
> +/* Function prototype declaration common between
> + * drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c and
> + * drivers/ptp/ptp_pch.c.*/
> +
> +u32 pch_ch_control_read(struct pci_dev *pdev);
> +void pch_ch_control_write(struct pci_dev *pdev, u32 val);
> +u32 pch_ch_event_read(struct pci_dev *pdev);
> +void pch_ch_event_write(struct pci_dev *pdev, u32 val);
> +u32 pch_src_uuid_lo_read(struct pci_dev *pdev);
> +u32 pch_src_uuid_hi_read(struct pci_dev *pdev);
> +u64 pch_rx_snap_read(struct pci_dev *pdev);
> +u64 pch_tx_snap_read(struct pci_dev *pdev);
> +int pch_set_station_address(u8 *addr, struct pci_dev *pdev);
> --=20
> 1.7.9.5
>=20
