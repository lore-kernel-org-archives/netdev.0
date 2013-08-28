From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next  04/10] ixgbe: fix link test when connected to 1Gbps
 link partner
Date: Wed, 28 Aug 2013 22:28:24 +0400
Message-ID: <521E4148.3030402@cogentembedded.com>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com> <1377686028-30747-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:62481 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752980Ab3H1S2e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 14:28:34 -0400
Received: by mail-la0-f54.google.com with SMTP id ea20so5160236lab.13
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 11:28:33 -0700 (PDT)
In-Reply-To: <1377686028-30747-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/28/2013 02:33 PM, Jeff Kirsher wrote:

> From: Emil Tantilov <emil.s.tantilov@intel.com>

> This patch is a partial reverse of:
> commit dfcc4615f09c33454bc553567f7c7506cae60cb9

    Please also specify that commit's summary line in parens.

> Specifically forcing the laser before the link check can lead to
> inconsistent results because it does not guarantee that the link will be
> negotiated correctly. Such is the case when dual speed SFP+ module is
> connected to a gigabit link partner.

> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 26 ++++++++----------------
>   1 file changed, 9 insertions(+), 17 deletions(-)

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> index db0dbf6..57465d8 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
> @@ -1885,11 +1885,11 @@ static void ixgbe_diag_test(struct net_device *netdev,
>                               struct ethtool_test *eth_test, u64 *data)
>   {
>   	struct ixgbe_adapter *adapter = netdev_priv(netdev);
> -	struct ixgbe_hw *hw = &adapter->hw;
>   	bool if_running = netif_running(netdev);
>
>   	set_bit(__IXGBE_TESTING, &adapter->state);
>   	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
> +		struct ixgbe_hw *hw = &adapter->hw;

    Empty line wouldn't here, after declaration. At least in the code above 
you have it.

>   		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
>   			int i;
>   			for (i = 0; i < adapter->num_vfs; i++) {

WBR, Sergei
