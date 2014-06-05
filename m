From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 06/14] i40e: clamp jumbo frame size
Date: Thu, 5 Jun 2014 08:17:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17257A04@AcuExch.aculab.com>
References: <1401954567-13557-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1401954567-13557-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: 'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42952 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750916AbaFEISD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 04:18:03 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10807-04 for <netdev@vger.kernel.org>;
 Thu,  5 Jun 2014 09:17:53 +0100 (BST)
In-Reply-To: <1401954567-13557-7-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The driver was allowing the user to set larger size MTU
> than the hardware was being configured to support.
> 
> The driver was already using VLAN_HLEN when setting the
> hardware max receivable frame size, so just add it to the
> netdev MTU set entry point as well.
...
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -1698,7 +1698,7 @@ static void i40e_sync_filters_subtask(struct i40e_pf *pf)
>  static int i40e_change_mtu(struct net_device *netdev, int new_mtu)
>  {
>  	struct i40e_netdev_priv *np = netdev_priv(netdev);
> -	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
> +	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;

Personally I'd write that sum as:
	int max_frame = ETH_HLEN + VLAN_HLEN + new_mtu + ETH_FCS_LEN;
so that the lengths are in the order the fields appear in the frame.

	David
