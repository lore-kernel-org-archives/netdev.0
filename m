From: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Subject: RE: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Tue, 24 Apr 2012 05:07:25 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB3103432@HASMSX103.ger.corp.intel.com>
References: <20120424124803.f4dc75ea96a875c3f35db615@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120424124803.f4dc75ea96a875c3f35db615@canb.auug.org.au>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> Hi John,
> 
> Today's linux-next merge of the wireless-next tree got a conflict in
> drivers/net/wireless/iwlwifi/iwl-testmode.c between commit d33e152e1edd
> ("iwlwifi: Stop using NLA_PUT*()") from the net-next tree and commit
> 2152268ff911 ("iwlwifi: op_mode holds its pointer to the config") from the
> wireless-next tree.
> 
> I was hoping that we were done with these ... :-(
> 
> I fixed it up (see below) and can carry the fix as necessary.

Thanks Stephen, your fix seems right. In this case, there are only two choices: it is right or it doesn't even compile.

> 
> --
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
> 
> diff --cc drivers/net/wireless/iwlwifi/iwl-testmode.c
> index bb27509,a6b16aa..0000000
> --- a/drivers/net/wireless/iwlwifi/iwl-testmode.c
> +++ b/drivers/net/wireless/iwlwifi/iwl-testmode.c
> @@@ -543,12 -539,11 +543,12 @@@ static int iwl_testmode_driver(struct i
>   				IWL_ERR(priv, "Memory allocation fail\n");
>   				return -ENOMEM;
>   			}
>  -			NLA_PUT_U32(skb, IWL_TM_ATTR_COMMAND,
>  -				IWL_TM_CMD_DEV2APP_EEPROM_RSP);
>  -			NLA_PUT(skb, IWL_TM_ATTR_EEPROM,
>  -				priv->cfg->base_params->eeprom_size,
>  -				priv->eeprom);
>  +			if (nla_put_u32(skb, IWL_TM_ATTR_COMMAND,
>  +					IWL_TM_CMD_DEV2APP_EEPROM_RSP) ||
>  +			    nla_put(skb, IWL_TM_ATTR_EEPROM,
> - 				    cfg(priv)->base_params->eeprom_size,
> ++				    priv->cfg->base_params->eeprom_size,
>  +				    priv->eeprom))
>  +				goto nla_put_failure;
>   			status = cfg80211_testmode_reply(skb);
>   			if (status < 0)
>   				IWL_ERR(priv, "Error sending msg : %d\n",
---------------------------------------------------------------------
Intel Israel (74) Limited

This e-mail and any attachments may contain confidential material for
the sole use of the intended recipient(s). Any review or distribution
by others is strictly prohibited. If you are not the intended
recipient, please contact the sender and delete all copies.
