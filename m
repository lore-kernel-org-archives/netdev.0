From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 12/15] i40e: remove Tx work for ptp
Date: Tue, 27 May 2014 10:51:10 +0300
Message-ID: <CAJZOPZJRjZ+od4-obYJfGbzTT0W1nRfCZvWeWa1VZbTD2vLdTQ@mail.gmail.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1400673673-31626-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:63792 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbaE0HvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 03:51:11 -0400
Received: by mail-qg0-f52.google.com with SMTP id a108so13016202qge.25
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 00:51:10 -0700 (PDT)
In-Reply-To: <1400673673-31626-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 3:01 PM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
>
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>
> The previous removal of the PTP Tx work functionality was
> incomplete as noted by Jake Keller. This removal allows
> us to rely on the Tx timesync interrupt.

This patch removes a define of  I40E_PTP_TX_TIMEOUT and stats entry for
tx_hwtstamp_timeouts, I am not sure to see how this removal allows the driver to
rely on the Tx timesync interrupt, maybe wrong change-log?



>
> CC: Jacob Keller <jacob.e.keller@intel.com>
> Change-ID: Id4faaf275a3688053ebbf07bef08072f9fd11aa9
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 1 -
>  drivers/net/ethernet/intel/i40e/i40e_ptp.c     | 1 -
>  2 files changed, 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> index 7f3d342..861e1db 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
> @@ -112,7 +112,6 @@ static struct i40e_stats i40e_gstrings_stats[] = {
>         I40E_PF_STAT("rx_oversize", stats.rx_oversize),
>         I40E_PF_STAT("rx_jabber", stats.rx_jabber),
>         I40E_PF_STAT("VF_admin_queue_requests", vf_aq_requests),
> -       I40E_PF_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
>         I40E_PF_STAT("rx_hwtstamp_cleared", rx_hwtstamp_cleared),
>         /* LPI stats */
>         I40E_PF_STAT("tx_lpi_status", stats.tx_lpi_status),
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
> index 1fedc7a..101f439 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
> @@ -48,7 +48,6 @@
>                                         I40E_PRTTSYN_CTL1_TSYNTYPE_SHIFT)
>  #define I40E_PRTTSYN_CTL1_TSYNTYPE_V2  (0x2 << \
>                                         I40E_PRTTSYN_CTL1_TSYNTYPE_SHIFT)
> -#define I40E_PTP_TX_TIMEOUT  (HZ * 15)
>
>  /**
>   * i40e_ptp_read - Read the PHC time from the device
> --
> 1.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
