From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 net-next 2/2] igb: support SIOCSMIIREG
Date: Thu, 07 May 2015 10:52:06 -0700
Message-ID: <554BA646.1060000@gmail.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com> <1429302240-654-2-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, gospo@cumulusnetworks.com,
	shm@cumulusnetworks.com, Alan Liebthal <alanl@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34554 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbbEGRwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 13:52:08 -0400
Received: by pdbqa5 with SMTP id qa5so47520161pdb.1
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 10:52:08 -0700 (PDT)
In-Reply-To: <1429302240-654-2-git-send-email-jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2015 01:24 PM, Jonathan Toppins wrote:
> From: Alan Liebthal <alanl@cumulusnetworks.com>
>
> Support setting the MII register via SIOCSMIIREG.
>
> Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
>   drivers/net/ethernet/intel/igb/igb_main.c |    5 +++++
>   1 file changed, 5 insertions(+)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 720b785..1071a71 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -7141,6 +7141,11 @@ static int igb_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
>   			return -EIO;
>   		break;
>   	case SIOCSMIIREG:
> +		adapter->hw.phy.addr = data->phy_id;
> +		if (igb_write_phy_reg(&adapter->hw, data->reg_num & 0x1F,
> +				      data->val_in))
> +			return -EIO;
> +		break;
>   	default:
>   		return -EOPNOTSUPP;
>   	}

How and why is this being used?  From what I can tell it looks like it 
is an easy way to break any of the existing interfaces if it is misused 
since all you would need to do is specify a phy address that doesn't 
match the existing PHY in the system and then you would likely lose 
link, or possibly mess up the configuration on the system requiring.

I suspect this is a back door for some piece of user space code that is 
being given far more permission than it should be.

- Alex
