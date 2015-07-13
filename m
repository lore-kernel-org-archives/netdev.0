From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 12/16] i40evf: don't delete all the filters
Date: Mon, 13 Jul 2015 15:51:08 +0300
Message-ID: <55A3B43C.5010806@cogentembedded.com>
References: <1436778517-16254-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1436778517-16254-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:35303 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbbGMMvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 08:51:15 -0400
Received: by lahh5 with SMTP id h5so15761790lah.2
        for <netdev@vger.kernel.org>; Mon, 13 Jul 2015 05:51:14 -0700 (PDT)
In-Reply-To: <1436778517-16254-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 7/13/2015 12:08 PM, Jeff Kirsher wrote:

> From: Mitch Williams <mitch.a.williams@intel.com>

> Due to an inverted conditional, the driver was marking all of its MAC
> filters for deletion every time set_rx_mode was called. Depending upon
> the timing of the calls to set_rx_mode and the processing of the admin
> queue, the driver would (accidentally) end up with a varying number of
> functional filters.

> Correct this logic so that MAC filters are added and removed correctly.
> Add a check for the driver's "hardware" MAC address so that this filter
> doesn't get removed incorrectly.

> Change-ID: Ib3e7c4a5b53df6835f164fe44cb778cb71f8aff8
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Tested-by: Jim Young <james.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40evf/i40evf_main.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> index 94eff4a..07f6052 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> @@ -892,8 +892,10 @@ static void i40evf_set_rx_mode(struct net_device *netdev)
>   					break;
>   				}
>   			}
> +			if (ether_addr_equal(f->macaddr, adapter->hw.mac.addr))
> +					found = true;

    This line is indented too much.

[...]

WBR, Sergei
