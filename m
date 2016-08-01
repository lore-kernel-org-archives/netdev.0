From: Amitkumar Karwar <akarwar@marvell.com>
Subject: RE: [PATCH 1/1] mwifiex: key_material_v2 remove superfluous condition
Date: Mon, 1 Aug 2016 10:46:47 +0000
Message-ID: <d5e7a66bc98b43eab031836908667c2c@SC-EXCH04.marvell.com>
References: <877fc2816w.fsf@purkki.adurom.net>
 <1469967081-3937-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Heinrich Schuchardt <xypron.glpk@gmx.de>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:32350 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751162AbcHAKtR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 06:49:17 -0400
In-Reply-To: <1469967081-3937-1-git-send-email-xypron.glpk@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Heinrich Schuchardt [mailto:xypron.glpk@gmx.de]
> Sent: Sunday, July 31, 2016 5:41 PM
> To: Amitkumar Karwar; Nishant Sarmukadam; Kalle Valo
> Cc: linux-wireless@vger.kernel.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Heinrich Schuchardt
> Subject: [PATCH 1/1] mwifiex: key_material_v2 remove superfluous
> condition
> 
> We are using mac as source address in a memcpy.
> In the lines below we can assume mac is not NULL.
> 
> Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
> ---
>  drivers/net/wireless/marvell/mwifiex/sta_cmd.c | 11 +++--------
>  1 file changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
> b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
> index 128add8..0d4f9fe 100644
> --- a/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
> +++ b/drivers/net/wireless/marvell/mwifiex/sta_cmd.c
> @@ -706,15 +706,10 @@ mwifiex_cmd_802_11_key_material_v2(struct
> mwifiex_private *priv,
>  				    (priv->wep_key_curr_index & KEY_INDEX_MASK))
>  					key_info |= KEY_DEFAULT;
>  			} else {
> -				if (mac) {
> -					if (is_broadcast_ether_addr(mac))
> -						key_info |= KEY_MCAST;
> -					else
> -						key_info |= KEY_UNICAST |
> -							    KEY_DEFAULT;
> -				} else {
> +				if (is_broadcast_ether_addr(mac))
>  					key_info |= KEY_MCAST;
> -				}
> +				else
> +					key_info |= KEY_UNICAST | KEY_DEFAULT;
>  			}
>  		}
>  		km->key_param_set.key_info = cpu_to_le16(key_info);
> --
> 2.8.1

Looks ok to me.

Acked-by: Amitkumar Karwar <akarwar@marvell.com>

Regards,
Amitkumar
