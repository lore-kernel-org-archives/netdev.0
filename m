From: Ethan Zhao <ethan.kernel@gmail.com>
Subject: Re: [PATCH] net: intel: e1000e: add check on e1e_wphy() return value
Date: Wed, 21 Jun 2017 10:44:16 +0800
Message-ID: <CABawtvMeV9=_hhECX1hkVE5+fOytBdaf2pYtSU9xAfY_yPK-Uw@mail.gmail.com>
References: <20170518172223.Horde.5kLLwxMJWThQKv0bAxTsk4D@gator4166.hostgator.com>
 <20170620212234.GA10957@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620212234.GA10957@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gustavo,

   The return value of ret_val seems used to check if the access to PHY/NVM
got its semaphore,  generally speaking, it is needed for every PHY
access of this driver.

Reviewed-by: Ethan Zhao <ethan.zhao@oracle.com>

On Wed, Jun 21, 2017 at 5:22 AM, Gustavo A. R. Silva
<garsilva@embeddedor.com> wrote:
> Check return value from call to e1e_wphy(). This value is being
> checked during previous calls to function e1e_wphy() and it seems
> a check was missing here.
>
> Addresses-Coverity-ID: 1226905
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> index 68ea8b4..d6d4ed7 100644
> --- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
> +++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
> @@ -2437,6 +2437,8 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
>                 if (hw->phy.revision < 2) {
>                         e1000e_phy_sw_reset(hw);
>                         ret_val = e1e_wphy(hw, MII_BMCR, 0x3140);
> +                       if (ret_val)
> +                               return ret_val;
>                 }
>         }
>
> --
> 2.5.0
>
