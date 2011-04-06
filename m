From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH net-next-2.6 12/12] qlcnic: convert to set_phys_id
Date: Wed, 6 Apr 2011 05:47:30 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80FD1383A36@MNEXMB2.qlogic.org>
References: <20110404184340.604594357@linuxplumber.net>
 <20110404184502.382340801@linuxplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1outboundpool.messaging.microsoft.com ([216.32.181.183]:5776
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975Ab1DFKrk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 06:47:40 -0400
In-Reply-To: <20110404184502.382340801@linuxplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +             ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
>               if (ret) {
> -                     clear_bit(__QLCNIC_RESETTING, &adapter->state);
> -                     return ret;
> +                     dev_err(&adapter->pdev->dev,
> +                             "Failed to set LED blink state.\n");
> +                     break;
>               }
> -     }
> -
> -     ret = adapter->nic_ops->config_led(adapter, 1, 0xf);
> -     if (ret) {
> -             dev_err(&adapter->pdev->dev,
> -                     "Failed to set LED blink state.\n");
> -             goto done;
> -     }
> +             return 0;
>
> -     msleep_interruptible(val * 1000);
> +     case ETHTOOL_ID_INACTIVE:
> +             ret = adapter->nic_ops->config_led(adapter, 0, 0xf);
> +             if (ret)
> +                     dev_err(&adapter->pdev->dev,
> +                             "Failed to reset LED blink state.\n");
> +             break;
>
> -     ret = adapter->nic_ops->config_led(adapter, 0, 0xf);
> -     if (ret) {
> -             dev_err(&adapter->pdev->dev,
> -                     "Failed to reset LED blink state.\n");
> -             goto done;
> +     default:
> +             return -EINVAL;
>       }
>
> -done:
> -     if (dev_down) {
> +     if (!netif_running(dev)) {
>               qlcnic_diag_free_res(dev, max_sds_rings);
>               clear_bit(__QLCNIC_RESETTING, &adapter->state);
>       }
> -     return ret;
>
> +     return ret;
>  }
>
"return ret" is return value of adapter->nic_ops->config_led, which can return any Error value.
And you have special check for -EINVAL. Though currently config_led doesn't return -EINVAL, but in future it may break (as 'ret' comes from config_led() -> send_cmd_desc()).
So it will be better if you return some hard code error value instead of 'ret'.

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

