From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 3/6] igb: Don't let ethtool try to write to iNVM in
 i210/i211
Date: Fri, 01 Nov 2013 18:05:52 +0400
Message-ID: <5273B540.7010807@cogentembedded.com>
References: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com> <1383314210-24289-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Fujinaka, Todd" <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:39783 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab3KAOF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 10:05:56 -0400
Received: by mail-lb0-f169.google.com with SMTP id p9so1343862lbv.0
        for <netdev@vger.kernel.org>; Fri, 01 Nov 2013 07:05:55 -0700 (PDT)
In-Reply-To: <1383314210-24289-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01-11-2013 17:56, Jeff Kirsher wrote:

> From: "Fujinaka, Todd" <todd.fujinaka@intel.com>

> Don't let ethtool try to write to iNVM in i210/i211.

> This fixes an issue seen by Marek Vasut.

> Reported-by: Marek Vasut <marex@denx.de>
> Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> index 0ae3177..b918ba3 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -771,8 +771,10 @@ static int igb_set_eeprom(struct net_device *netdev,
>   	if (eeprom->len == 0)
>   		return -EOPNOTSUPP;
>
> -	if (hw->mac.type == e1000_i211)
> +	if ((hw->mac.type >= e1000_i210) &&
> +	    !igb_get_flash_presence_i210(hw)) {
>   		return -EOPNOTSUPP;
> +	}

    Why have you added {}?

WBR, Sergei
