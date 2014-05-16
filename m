From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Subject: RE: [PATCH] bnx2x: Convert return 0 to return rc
Date: Fri, 16 May 2014 12:02:14 +0000
Message-ID: <87B4DDAD5EAFA041BDC28F314593782D0172ECD7@avmb3.qlogic.org>
References: <1400223103.30884.5.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>, Ariel Elior <ariele@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400223103.30884.5.camel@joe-AO725>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Joe Perches
> Sent: Friday, May 16, 2014 9:52 AM
> To: Ariel Elior; Dmitry Kravkov
> Cc: netdev; linux-kernel
> Subject: [PATCH] bnx2x: Convert return 0 to return rc
>
> These "return 0;" uses seem wrong as there are
> rc variables where error return values are set
> but unused.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>
> Hey Ariel/Dmitry
>
> I've no idea what's right here, but the current
> code seems wrong. (or at least under-commented)
>
> It seems Dmitry changed these, perhaps to make
> it more readable, but the commit log isn't very
> instructive.
>
> commit 1d6f3cd8988822c7bdc3c685fac0a99315e83400
> Author: Dmitry Kravkov <dmitry@broadcom.com>
> Date:   Wed Mar 27 01:05:17 2013 +0000
>
>     bnx2x: Prevent VF race
>
>     The mail box containing the Vf-Pf messages is susceptible
>     to a race - it's possible for 2 flows to try and write commands,
>     causing one to override the other's message.
>     Use a mutex to synchronize the access, preventing said race.
>
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> index 81cc2d9..b8078d5 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
> @@ -2695,7 +2695,7 @@ out:
>               bnx2x_unlock_vf_pf_channel(bp, vf,
> CHANNEL_TLV_PF_SET_MAC);
>       }
>
> -     return 0;
> +     return rc;
>  }
>
>  int bnx2x_set_vf_vlan(struct net_device *dev, int vfidx, u16 vlan, u8 qos)
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> index 0c067e8..784c715 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
> @@ -747,7 +747,7 @@ int bnx2x_vfpf_config_mac(struct bnx2x *bp, u8
> *addr, u8 vf_qid, bool set)
>  out:
>       bnx2x_vfpf_finalize(bp, &req->first_tlv);
>
> -     return 0;
> +     return rc;
>  }
>
>  /* request pf to config rss table for vf queues*/
>

Thanks Joe for catching this!

Acked-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>


________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
