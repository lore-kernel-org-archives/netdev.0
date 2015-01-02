From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 2 Jan 2015 23:21:05 +0100
Message-ID: <CA+icZUUmm5=YAZCXtk+iBaewFremZ17M2uShx+jBa4=JcTuaQA@mail.gmail.com>
References: <20150103091101.04b2c11e@canb.auug.org.au>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-next <linux-next@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150103091101.04b2c11e@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 2, 2015 at 11:11 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
>
> drivers/net/ethernet/mellanox/mlx4/en_clock.c: In function 'mlx4_en_init_timestamp':
> drivers/net/ethernet/mellanox/mlx4/en_clock.c:249:2: error: implicit declaration of function 'CLOCKSOURCE_MASK' [-Werror=implicit-function-declaration]
>   mdev->cycles.mask = CLOCKSOURCE_MASK(48);
>   ^
> drivers/net/ethernet/mellanox/mlx4/en_clock.c:257:3: error: implicit declaration of function 'clocksource_khz2mult' [-Werror=implicit-function-declaration]
>    clocksource_khz2mult(1000 * dev->caps.hca_core_clock, mdev->cycles.shift);
>    ^
> drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c: In function 'ixgbe_ptp_start_cyclecounter':
> drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c:796:2: error: implicit declaration of function 'CLOCKSOURCE_MASK' [-Werror=implicit-function-declaration]
>   adapter->cc.mask = CLOCKSOURCE_MASK(64);
>   ^
>
> Presumably caused by commit 74d23cc704d1 ("time: move the
> timecounter/cyclecounter code into its own file").
>

Happy new 2015 Stephen...

[ The last days I revived my linux-next build-script inspired by
willing to test block-loop-mq v3 patchset against next-20141231 ]

Just FYI...

Richard posted a new patch-series "[PATCH net-next 0/7] Fixing the
"Time Counter fixes and improvements" on linux-nextdev fixing this.

- Sedat -

[1] https://lkml.org/lkml/2015/1/1/27

> I added the following commit for today:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Sat, 3 Jan 2015 09:07:21 +1100
> Subject: [PATCH] ixgbe_ptp, mlx4: Include clocksource.h to get CLOCKSOURCE_MASK
>
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 1 +
>  drivers/net/ethernet/mellanox/mlx4/en_clock.c | 1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
> index 47c29eaaa140..73548280cbae 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
> @@ -25,6 +25,7 @@
>    Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
>
>  *******************************************************************************/
> +#include <linux/clocksource.h>
>  #include "ixgbe.h"
>  #include <linux/ptp_classify.h>
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> index e9cce4f72b24..7c6ef4b48f8e 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
> @@ -31,6 +31,7 @@
>   *
>   */
>
> +#include <linux/clocksource.h>
>  #include <linux/mlx4/device.h>
>
>  #include "mlx4_en.h"
> --
> 2.1.4
>
> --
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
