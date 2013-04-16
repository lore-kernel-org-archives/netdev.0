From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] bond: add support to read speed and duplex via ethtool
Date: Wed, 17 Apr 2013 02:33:02 +0400
Message-ID: <516DD19E.5070803@cogentembedded.com>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net> <1366146607-12343-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:39135 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965426Ab3DPWdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 18:33:54 -0400
Received: by mail-la0-f47.google.com with SMTP id fk20so673524lab.20
        for <netdev@vger.kernel.org>; Tue, 16 Apr 2013 15:33:52 -0700 (PDT)
In-Reply-To: <1366146607-12343-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/17/2013 01:10 AM, Andy Gospodarek wrote:

> This patch adds support for the get_settings ethtool op to the bonding
> driver.  This was motivated by users who wanted to get the speed of the
> bond and compare that against throughput to understand utilization.
> The behavior before this patch was added was problematic when computing
> line utilization after trying to get link-speed and throughput via SNMP.
>
> Output from ethtool looks like this for a round-robin bond:
>
> Settings for bond0:
> 	Supported ports: [ ]
> 	Supported link modes:   Not reported
> 	Supported pause frame use: No
> 	Supports auto-negotiation: No
> 	Advertised link modes:  Not reported
> 	Advertised pause frame use: No
> 	Advertised auto-negotiation: No
> 	Speed: 11000Mb/s
> 	Duplex: Full
> 	Port: Other
> 	PHYAD: 0
> 	Transceiver: internal
> 	Auto-negotiation: off
> 	MDI-X: Unknown
> 	Link detected: yes
>
> I tested this and verified it works as expected.  A test was also done
> on a version backported to an older kernel and it worked well there.
>
> v2: switch to using ethtool_cmd_speed_set to set speed, added check to
> SLAVE_IS_OK for each slave in bond, dropped mode-specific calculations
> as they were not needed, and set port type to 'Other.'
>
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>   drivers/net/bonding/bond_main.c | 34 ++++++++++++++++++++++++++++++++++
>   1 file changed, 34 insertions(+)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 07401a3..da2dd38 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4222,6 +4222,39 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
>   	}
>   }
>   
> +static int bond_ethtool_get_settings(struct net_device *bond_dev,
> +				     struct ethtool_cmd *ecmd)
> +{
[...]
> +			if (slave->speed != SPEED_UNKNOWN) {
> +				speed += slave->speed;
> +			}

    {} not needed. scripts/checkpatch.pl should have probably complained.

WBR, Sergei
