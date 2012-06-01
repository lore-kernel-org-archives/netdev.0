From: Chris Boot <bootc@bootc.net>
Subject: Re: [PATCH 1/2] e1000e: Disable ASPM L1 on 82574
Date: Fri, 01 Jun 2012 22:17:08 +0100
Message-ID: <4FC93154.1060906@bootc.net>
References: <1335216578-21542-1-git-send-email-bootc@bootc.net>
	<1335216578-21542-2-git-send-email-bootc@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org, nix@esperi.org.uk
To: Chris Boot <bootc@bootc.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1335216578-21542-2-git-send-email-bootc@bootc.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 23/04/2012 22:29, Chris Boot wrote:
> ASPM on the 82574 causes trouble. Currently the driver disables L0s for
> this NIC but only disables L1 if the MTU is >1500. This patch simply
> causes L1 to be disabled regardless of the MTU setting.
>
> Signed-off-by: Chris Boot <bootc@bootc.net>
> Cc: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
> Cc: Nix <nix@esperi.org.uk>
> Link: https://lkml.org/lkml/2012/3/19/362
> ---
>  drivers/net/ethernet/intel/e1000e/82571.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
> index b3fdc69..c6d95f2 100644
> --- a/drivers/net/ethernet/intel/e1000e/82571.c
> +++ b/drivers/net/ethernet/intel/e1000e/82571.c
> @@ -2061,8 +2061,9 @@ const struct e1000_info e1000_82574_info = {
>  				  | FLAG_HAS_SMART_POWER_DOWN
>  				  | FLAG_HAS_AMT
>  				  | FLAG_HAS_CTRLEXT_ON_LOAD,
> -	.flags2			  = FLAG2_CHECK_PHY_HANG
> +	.flags2			= FLAG2_CHECK_PHY_HANG
>  				  | FLAG2_DISABLE_ASPM_L0S
> +				  | FLAG2_DISABLE_ASPM_L1
>  				  | FLAG2_NO_DISABLE_RX,
>  	.pba			= 32,
>  	.max_hw_frame_size	= DEFAULT_JUMBO,

Now that this patch is in master (d4a4206e) and has presumably been
widely tested, what's the possibility of it making it into stable? I
really should have included a CC to stable when I sent it...

This patch should probably also be accompanied with 59aed952 (e1000e:
Remove special case for 82573/82574 ASPM L1 disablement) on top, to
remove a special case that's no longer required once this is applied.

Thanks,
Chris

-- 
Chris Boot
bootc@bootc.net


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
