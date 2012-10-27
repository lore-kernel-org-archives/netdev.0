From: Konstantin Stepanyuk <konstantin.stepanyuk@gmail.com>
Subject: Re: [net-next 02/12] ixgbe: Fix return value from macvlan filter function
Date: Sat, 27 Oct 2012 12:36:52 -0600
Message-ID: <CAKgsOu-PH2OJRKxLWj=UEp=XuQCpu0e_pNL2_Nkbbz8Hx2bhEw@mail.gmail.com>
References: <1351296518-31174-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1351296518-31174-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, Greg Rose <gregory.v.rose@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:40766 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758499Ab2J0Sgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 14:36:53 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so4096933vcb.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 11:36:52 -0700 (PDT)
In-Reply-To: <1351296518-31174-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 26, 2012 at 6:08 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> From: Greg Rose <gregory.v.rose@intel.com>
>
> The function to set the macvlan filter should return success or failure
> instead of the index of the filter.  The message processing function was
> misinterpreting the index as a non-zero return code indicating failure and
> NACKing MAC filter set messages that actually succeeded.
>
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Tested-by: Robert Garrett <robertx.e.garrett@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> index 96876b7..b68bf0f 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
> @@ -742,7 +742,8 @@ static int ixgbe_set_vf_macvlan_msg(struct ixgbe_adapter *adapter,
>                 e_warn(drv,
>                        "VF %d has requested a MACVLAN filter but there is no space for it\n",
>                        vf);
> -       return err;
> +
> +       return !!err < 0;
This expression always resolves to false, either 0 < 0 or 1 < 0,
because '!' has higher precedence than '<'.

Thanks,
Konstantin
