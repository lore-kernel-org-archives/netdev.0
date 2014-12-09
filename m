From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 05/13] i40e: add range check to i40e_aq_rc_to_posix
Date: Tue, 09 Dec 2014 17:23:56 +0300
Message-ID: <548705FC.6020805@cogentembedded.com>
References: <1418124170-7495-1-git-send-email-jeffrey.t.kirsher@intel.com> <1418124170-7495-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:45401 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbaLIOYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 09:24:00 -0500
Received: by mail-lb0-f178.google.com with SMTP id f15so617687lbj.23
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 06:23:58 -0800 (PST)
In-Reply-To: <1418124170-7495-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/9/2014 2:22 PM, Jeff Kirsher wrote:

> From: Shannon Nelson <shannon.nelson@intel.com>

> Just to be sure, add a range check to avoid any possible
> array index-out-of-bound issues.

> Change-ID: I9323bee6732c2a47599816e1d6c6b3a1f8dcbf54
> Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> Acked-by: Michal Kosiarz <michal.kosiarz@intel.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_adminq.h   | 2 ++
>   drivers/net/ethernet/intel/i40evf/i40e_adminq.h | 2 ++
>   2 files changed, 4 insertions(+)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.h b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> index 618fe96..4064b1e 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.h
> @@ -136,6 +136,8 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
>   		-EFBIG,      /* I40E_AQ_RC_EFBIG */
>   	};
>
> +	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])))

    There's ARRAY_SIZE() macro exactly for such computations. And parens 
around the last 'aq_to_posix' are not needed.

> +		return -ERANGE;
>   	return aq_to_posix[aq_rc];
>   }
>
> diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
> index d5d3c93..4d63514 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
> +++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
> @@ -136,6 +136,8 @@ static inline int i40e_aq_rc_to_posix(u16 aq_rc)
>   		-EFBIG,      /* I40E_AQ_RC_EFBIG */
>   	};
>
> +	if (aq_rc >= (sizeof(aq_to_posix) / sizeof((aq_to_posix)[0])))

    Likewise.

[...]

WBR, Sergei
