From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC PATCH net-next 4/5] ixgbevf: Add RSS Key query code
Date: Tue, 30 Dec 2014 11:26:04 -0800
Message-ID: <CAL3LdT6zqehP+2DcqBj7uJwPRT1nY2aO5BJ8K=4kWFsgJVZYAQ@mail.gmail.com>
References: <1419957035-1078-1-git-send-email-vladz@cloudius-systems.com>
	<1419957035-1078-5-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Gleb Natapov <gleb@cloudius-systems.com>,
	Avi Kivity <avi@cloudius-systems.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:56876 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaL3T0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 14:26:05 -0500
Received: by mail-oi0-f45.google.com with SMTP id x69so33461590oia.4
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 11:26:04 -0800 (PST)
In-Reply-To: <1419957035-1078-5-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2014 at 8:30 AM, Vlad Zolotarov
<vladz@cloudius-systems.com> wrote:
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/mbx.h |  2 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c  | 48 ++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h  |  1 +
>  3 files changed, 51 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
> index 3e148a8..9674ac8 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
> +++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
> @@ -110,6 +110,8 @@ enum ixgbe_pfvf_api_rev {
>  #define IXGBE_VF_GET_RETA_1    0x0b /* get RETA[12..23] */
>  #define IXGBE_VF_GET_RETA_2    0x0c /* get RETA[24..31] */
>
> +#define IXGBE_VF_GET_RSS_KEY   0x0d /* get RSS hash key */
> +
>  /* GET_QUEUES return data indices within the mailbox */
>  #define IXGBE_VF_TX_QUEUES     1       /* number of Tx queues supported */
>  #define IXGBE_VF_RX_QUEUES     2       /* number of Rx queues supported */
> diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
> index 3ebc882..7987ab0 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/vf.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
> @@ -290,6 +290,54 @@ static inline int _ixgbevf_get_reta(struct ixgbe_hw *hw, u32 *msgbuf,
>  }
>
>  /**
> + * ixgbevf_get_rss_key - get the RSS Random Key
> + * @hw: pointer to the HW structure
> + * @reta: buffer to fill with RETA contents.
> + *
> + * The "rss_key" buffer should be big enough to contain 10 registers.
> + *
> + * Returns: 0 on success.
> + *          if API doesn't support this operation - (-EPERM).
> + */
> +int ixgbevf_get_rss_key(struct ixgbe_hw *hw, u8 *rss_key)
> +{
> +       int err;
> +       u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
> +
> +       /* Return and error if API doesn't support RSS Random Key retrieval */
> +       switch (hw->api_version) {
> +       case ixgbe_mbox_api_12:
> +               break;
> +       default:
> +               return -EPERM;
> +       }

An if statement here as well, instead of a switch statement.
