From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: changed some expensive calls of
 udelay to usleep_range
Date: Tue, 29 Aug 2017 10:19:09 +0300
Message-ID: <a2ff6002-3d8f-1094-c05e-696b1cd07256@intel.com>
References: <1503503985-3869-1-git-send-email-matthew.tan_1@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: michael.kardonik@nxp.com, mitch.a.williams@intel.com,
        linux-kernel@vger.kernel.org, john.ronciak@intel.com,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Matthew Tan <matthew.tan_1@nxp.com>, jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503503985-3869-1-git-send-email-matthew.tan_1@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/23/2017 18:59, Matthew Tan wrote:
>      Calls to udelay are not preemtable by userspace so userspace
>      applications experience a large (~200us) latency when running on core
>      0. Instead usleep_range can be used to be more friendly to userspace
>      since it is preemtable. This is due to udelay using busy-wait loops
>      while usleep_rang uses hrtimers instead. It is recommended to use
>      udelay when the delay is <10us since at that precision overhead of
>      usleep_range hrtimer setup causes issues. However, the replaced calls
>      are for 50us and 100us so this should not be not an issue.
>
> Signed-off-by: Matthew Tan <matthew.tan_1@nxp.com>
> ---
>   drivers/net/ethernet/intel/e1000e/phy.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
> index de13aea..e318fdc 100644
> --- a/drivers/net/ethernet/intel/e1000e/phy.c
> +++ b/drivers/net/ethernet/intel/e1000e/phy.c
> @@ -158,7 +158,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
>   	 * the lower time out
>   	 */
>   	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
> -		udelay(50);
> +		usleep_range(40, 60);
>   		mdic = er32(MDIC);
>   		if (mdic & E1000_MDIC_READY)
>   			break;
> @@ -183,7 +183,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
>   	 * reading duplicate data in the next MDIC transaction.
>   	 */
>   	if (hw->mac.type == e1000_pch2lan)
> -		udelay(100);
> +		usleep_range(90, 100);
>   
>   	return 0;
>   }
> @@ -222,7 +222,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
>   	 * the lower time out
>   	 */
>   	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
> -		udelay(50);
> +		usleep_range(40, 60);
>   		mdic = er32(MDIC);
>   		if (mdic & E1000_MDIC_READY)
>   			break;
> @@ -246,7 +246,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
>   	 * reading duplicate data in the next MDIC transaction.
>   	 */
>   	if (hw->mac.type == e1000_pch2lan)
> -		udelay(100);
> +		usleep_range(90, 110);
>   
>   	return 0;
>   }

Reasonable. Do you have any open bug or other reference describe this 
problem?
