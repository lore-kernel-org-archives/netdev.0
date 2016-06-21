From: Peter Oh <poh-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH 0/3] *** Mesh Path Selection Metric Calculation ***
Date: Mon, 20 Jun 2016 17:10:30 -0700
Message-ID: <576885F6.3010409@codeaurora.org>
References: <1466427622-5953-1-git-send-email-maxim.altshul@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=euc-kr
Content-Transfer-Encoding: 7bit
Cc: eliad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, yanivma-l0cyMroinI0@public.gmane.org, guym-l0cyMroinI0@public.gmane.org, arik-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Maxim Altshul <maxim.altshul-l0cyMroinI0@public.gmane.org>, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466427622-5953-1-git-send-email-maxim.altshul-l0cyMroinI0@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

where is 2/3 ?
On 06/20/2016 06:00 AM, Maxim Altshul wrote:
> Hi All,
> This patch series focuses on metric calculation that
> occurs during the path selection phase of a mesh network.
>
> During the path selection phase, the mesh hwmp module
> performs metric calculations, that take as parameters
> the last TX rate that was used for a specific link,
> and the packet error rate.
>
> These parameters should be reported by the FW to the driver
> constantly for the mechanism to work properly.
>
> In case that a vendor offloads the rate control mechanism
> to the FW, these parameters will be rarely updated,
> or updated incorrectly.
>
> This situation causes the mesh hwmp module to calculate incorrect
> metrics and as a consequence, not to choose the best paths possible.
>
>
> This patch series is divided to three patches and does the following:
>
> 1. Modifies mesh hwmp module and allows vendors that offload the
> rate control mechanism to their FW, to report last TX rates and PER
> to the mesh hwmp module by using an existing op called
> get_expected_throughput.
> In case that a vendor does not implement the op, all previous
> functionality still applies.
>
> 2. Implements the opcode and the mechanism that reports the rates
> in TI driver.
>
> Maxim Altshul (3):
>   wlcore/wl18xx: Add functionality to accept TX rate per link
>   wlcore: Add support for get_expected_throughput opcode
>   mac80211: mesh: Add support for HW RC implementation
>
>  drivers/net/wireless/ti/wl18xx/main.c     |  4 ++++
>  drivers/net/wireless/ti/wl18xx/tx.c       | 22 ++++++++++++++++++----
>  drivers/net/wireless/ti/wl18xx/wl18xx.h   |  6 +++++-
>  drivers/net/wireless/ti/wlcore/main.c     | 16 ++++++++++++++++
>  drivers/net/wireless/ti/wlcore/rx.c       |  7 +++++++
>  drivers/net/wireless/ti/wlcore/wlcore_i.h | 13 +++++++++++++
>  net/mac80211/mesh_hwmp.c                  | 23 +++++++++++++++--------
>  7 files changed, 78 insertions(+), 13 deletions(-)
>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
