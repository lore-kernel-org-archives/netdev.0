From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Sat, 07 Dec 2013 22:00:21 +0400
Message-ID: <52A36235.1040406@cogentembedded.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com> <1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:53888 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180Ab3LGSAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 13:00:18 -0500
Received: by mail-lb0-f180.google.com with SMTP id w6so766083lbh.39
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 10:00:17 -0800 (PST)
In-Reply-To: <1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07-12-2013 6:17, Jeff Kirsher wrote:

> From: Anjali Singhai Jain <anjali.singhai@intel.com>

> RSS can steer packets based on recognition of all
> sorts of different headers.  Enable some more of them.

> Change-Id: I2264dedae66fb0bceca6fb6e772e050e3ca8efc8

    This line has no place in the upstream patches, and I'm seeing it in 
several patches of this series.

> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c | 38 ++++++++++++++++++-----------
>   1 file changed, 24 insertions(+), 14 deletions(-)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
> index 273db99..40c64c4 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -5615,15 +5615,34 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
>    **/
>   static int i40e_config_rss(struct i40e_pf *pf)
>   {
> -	struct i40e_hw *hw = &pf->hw;
> -	u32 lut = 0;
> -	int i, j;
> -	u64 hena;
> +	const u64 default_hena =
> +			((u64)1 << I40E_FILTER_PCTYPE_NONF_UNICAST_IPV4_UDP) |

    1ULL not good enough?

[...]

WBR, Sergei
