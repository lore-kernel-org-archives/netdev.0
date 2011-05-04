From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2] libertas: Convert lbs_pr_<level> to pr_<level>
Date: Wed, 04 May 2011 17:15:25 -0500
Message-ID: <1304547327.4379.0.camel@dcbw.foobar.com>
References: <cover.1304379925.git.joe@perches.com>
	 <353dfb1607172b5a3dbaccddbe52c24312d42af4.1304379925.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <353dfb1607172b5a3dbaccddbe52c24312d42af4.1304379925.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-05-02 at 16:49 -0700, Joe Perches wrote:
> Use the standard pr_<level> functions eases grep a bit.
> 
> Added a few missing terminating newlines to messages.
> Coalesced long formats.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Dan Williams <dcbw@redhat.com>

> ---
>  drivers/net/wireless/libertas/cfg.c     |   15 +++---
>  drivers/net/wireless/libertas/cmd.c     |   36 +++++++-------
>  drivers/net/wireless/libertas/cmdresp.c |   29 +++++++-----
>  drivers/net/wireless/libertas/debugfs.c |    6 ++-
>  drivers/net/wireless/libertas/defs.h    |    7 ---
>  drivers/net/wireless/libertas/if_cs.c   |   52 +++++++++++----------
>  drivers/net/wireless/libertas/if_sdio.c |   38 ++++++++--------
>  drivers/net/wireless/libertas/if_spi.c  |   74 ++++++++++++++-----------------
>  drivers/net/wireless/libertas/if_usb.c  |   41 +++++++++--------
>  drivers/net/wireless/libertas/main.c    |   33 +++++++-------
>  drivers/net/wireless/libertas/mesh.c    |    8 ++-
>  drivers/net/wireless/libertas/rx.c      |    7 ++-
>  12 files changed, 174 insertions(+), 172 deletions(-)
> 
> diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
> index 5caa2ac..d6e0656 100644
> --- a/drivers/net/wireless/libertas/cfg.c
> +++ b/drivers/net/wireless/libertas/cfg.c
> @@ -6,6 +6,8 @@
>   *
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/sched.h>
>  #include <linux/wait.h>
>  #include <linux/slab.h>
> @@ -1314,8 +1316,7 @@ static int lbs_cfg_connect(struct wiphy *wiphy, struct net_device *dev,
>  		sme->ssid, sme->ssid_len,
>  		WLAN_CAPABILITY_ESS, WLAN_CAPABILITY_ESS);
>  	if (!bss) {
> -		lbs_pr_err("assoc: bss %pM not in scan results\n",
> -			   sme->bssid);
> +		pr_err("assoc: bss %pM not in scan results\n", sme->bssid);
>  		ret = -ENOENT;
>  		goto done;
>  	}
> @@ -1372,8 +1373,8 @@ static int lbs_cfg_connect(struct wiphy *wiphy, struct net_device *dev,
>  		lbs_enable_rsn(priv, sme->crypto.cipher_group != 0);
>  		break;
>  	default:
> -		lbs_pr_err("unsupported cipher group 0x%x\n",
> -			   sme->crypto.cipher_group);
> +		pr_err("unsupported cipher group 0x%x\n",
> +		       sme->crypto.cipher_group);
>  		ret = -ENOTSUPP;
>  		goto done;
>  	}
> @@ -1491,7 +1492,7 @@ static int lbs_cfg_add_key(struct wiphy *wiphy, struct net_device *netdev,
>  				     params->key, params->key_len);
>  		break;
>  	default:
> -		lbs_pr_err("unhandled cipher 0x%x\n", params->cipher);
> +		pr_err("unhandled cipher 0x%x\n", params->cipher);
>  		ret = -ENOTSUPP;
>  		break;
>  	}
> @@ -2118,13 +2119,13 @@ int lbs_cfg_register(struct lbs_private *priv)
>  
>  	ret = wiphy_register(wdev->wiphy);
>  	if (ret < 0)
> -		lbs_pr_err("cannot register wiphy device\n");
> +		pr_err("cannot register wiphy device\n");
>  
>  	priv->wiphy_registered = true;
>  
>  	ret = register_netdev(priv->dev);
>  	if (ret)
> -		lbs_pr_err("cannot register network device\n");
> +		pr_err("cannot register network device\n");
>  
>  	INIT_DELAYED_WORK(&priv->scan_work, lbs_scan_worker);
>  
> diff --git a/drivers/net/wireless/libertas/cmd.c b/drivers/net/wireless/libertas/cmd.c
> index 7e8a658..10ca485 100644
> --- a/drivers/net/wireless/libertas/cmd.c
> +++ b/drivers/net/wireless/libertas/cmd.c
> @@ -3,6 +3,8 @@
>    * It prepares command and sends it to firmware when it is ready.
>    */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/kfifo.h>
>  #include <linux/sched.h>
>  #include <linux/slab.h>
> @@ -108,7 +110,7 @@ int lbs_update_hw_spec(struct lbs_private *priv)
>  	 * CF card    firmware 5.0.16p0:   cap 0x00000303
>  	 * USB dongle firmware 5.110.17p2: cap 0x00000303
>  	 */
> -	lbs_pr_info("%pM, fw %u.%u.%up%u, cap 0x%08x\n",
> +	pr_info("%pM, fw %u.%u.%up%u, cap 0x%08x\n",
>  		cmd.permanentaddr,
>  		priv->fwrelease >> 24 & 0xff,
>  		priv->fwrelease >> 16 & 0xff,
> @@ -139,7 +141,7 @@ int lbs_update_hw_spec(struct lbs_private *priv)
>  	/* if it's unidentified region code, use the default (USA) */
>  	if (i >= MRVDRV_MAX_REGION_CODE) {
>  		priv->regioncode = 0x10;
> -		lbs_pr_info("unidentified region code; using the default (USA)\n");
> +		pr_info("unidentified region code; using the default (USA)\n");
>  	}
>  
>  	if (priv->current_addr[0] == 0xff)
> @@ -209,7 +211,7 @@ int lbs_host_sleep_cfg(struct lbs_private *priv, uint32_t criteria,
>  					(uint8_t *)&cmd_config.wol_conf,
>  					sizeof(struct wol_config));
>  	} else {
> -		lbs_pr_info("HOST_SLEEP_CFG failed %d\n", ret);
> +		pr_info("HOST_SLEEP_CFG failed %d\n", ret);
>  	}
>  
>  	return ret;
> @@ -312,7 +314,7 @@ static int lbs_wait_for_ds_awake(struct lbs_private *priv)
>  	if (priv->is_deep_sleep) {
>  		if (!wait_event_interruptible_timeout(priv->ds_awake_q,
>  					!priv->is_deep_sleep, (10 * HZ))) {
> -			lbs_pr_err("ds_awake_q: timer expired\n");
> +			pr_err("ds_awake_q: timer expired\n");
>  			ret = -1;
>  		}
>  	}
> @@ -337,7 +339,7 @@ int lbs_set_deep_sleep(struct lbs_private *priv, int deep_sleep)
>  				netif_carrier_off(priv->dev);
>  			}
>  		} else {
> -			lbs_pr_err("deep sleep: already enabled\n");
> +			pr_err("deep sleep: already enabled\n");
>  		}
>  	} else {
>  		if (priv->is_deep_sleep) {
> @@ -347,8 +349,7 @@ int lbs_set_deep_sleep(struct lbs_private *priv, int deep_sleep)
>  			if (!ret) {
>  				ret = lbs_wait_for_ds_awake(priv);
>  				if (ret)
> -					lbs_pr_err("deep sleep: wakeup"
> -							"failed\n");
> +					pr_err("deep sleep: wakeup failed\n");
>  			}
>  		}
>  	}
> @@ -382,8 +383,8 @@ int lbs_set_host_sleep(struct lbs_private *priv, int host_sleep)
>  			ret = lbs_host_sleep_cfg(priv, priv->wol_criteria,
>  					(struct wol_config *)NULL);
>  			if (ret) {
> -				lbs_pr_info("Host sleep configuration failed: "
> -						"%d\n", ret);
> +				pr_info("Host sleep configuration failed: %d\n",
> +					ret);
>  				return ret;
>  			}
>  			if (priv->psstate == PS_STATE_FULL_POWER) {
> @@ -393,19 +394,19 @@ int lbs_set_host_sleep(struct lbs_private *priv, int host_sleep)
>  						sizeof(cmd),
>  						lbs_ret_host_sleep_activate, 0);
>  				if (ret)
> -					lbs_pr_info("HOST_SLEEP_ACTIVATE "
> -							"failed: %d\n", ret);
> +					pr_info("HOST_SLEEP_ACTIVATE failed: %d\n",
> +						ret);
>  			}
>  
>  			if (!wait_event_interruptible_timeout(
>  						priv->host_sleep_q,
>  						priv->is_host_sleep_activated,
>  						(10 * HZ))) {
> -				lbs_pr_err("host_sleep_q: timer expired\n");
> +				pr_err("host_sleep_q: timer expired\n");
>  				ret = -1;
>  			}
>  		} else {
> -			lbs_pr_err("host sleep: already enabled\n");
> +			pr_err("host sleep: already enabled\n");
>  		}
>  	} else {
>  		if (priv->is_host_sleep_activated)
> @@ -1002,7 +1003,7 @@ static void lbs_submit_command(struct lbs_private *priv,
>  	ret = priv->hw_host_to_card(priv, MVMS_CMD, (u8 *) cmd, cmdsize);
>  
>  	if (ret) {
> -		lbs_pr_info("DNLD_CMD: hw_host_to_card failed: %d\n", ret);
> +		pr_info("DNLD_CMD: hw_host_to_card failed: %d\n", ret);
>  		/* Let the timer kick in and retry, and potentially reset
>  		   the whole thing if the condition persists */
>  		timeo = HZ/4;
> @@ -1267,7 +1268,7 @@ int lbs_execute_next_command(struct lbs_private *priv)
>  	spin_lock_irqsave(&priv->driver_lock, flags);
>  
>  	if (priv->cur_cmd) {
> -		lbs_pr_alert( "EXEC_NEXT_CMD: already processing command!\n");
> +		pr_alert( "EXEC_NEXT_CMD: already processing command!\n");
>  		spin_unlock_irqrestore(&priv->driver_lock, flags);
>  		ret = -1;
>  		goto done;
> @@ -1429,7 +1430,7 @@ static void lbs_send_confirmsleep(struct lbs_private *priv)
>  	ret = priv->hw_host_to_card(priv, MVMS_CMD, (u8 *) &confirm_sleep,
>  		sizeof(confirm_sleep));
>  	if (ret) {
> -		lbs_pr_alert("confirm_sleep failed\n");
> +		pr_alert("confirm_sleep failed\n");
>  		goto out;
>  	}
>  
> @@ -1655,8 +1656,7 @@ int __lbs_cmd(struct lbs_private *priv, uint16_t command,
>  	spin_lock_irqsave(&priv->driver_lock, flags);
>  	ret = cmdnode->result;
>  	if (ret)
> -		lbs_pr_info("PREP_CMD: command 0x%04x failed: %d\n",
> -			    command, ret);
> +		pr_info("PREP_CMD: command 0x%04x failed: %d\n", command, ret);
>  
>  	__lbs_cleanup_and_insert_cmd(priv, cmdnode);
>  	spin_unlock_irqrestore(&priv->driver_lock, flags);
> diff --git a/drivers/net/wireless/libertas/cmdresp.c b/drivers/net/wireless/libertas/cmdresp.c
> index 5e95da9..2cb6f5f 100644
> --- a/drivers/net/wireless/libertas/cmdresp.c
> +++ b/drivers/net/wireless/libertas/cmdresp.c
> @@ -2,6 +2,9 @@
>    * This file contains the handling of command
>    * responses as well as events generated by firmware.
>    */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/slab.h>
>  #include <linux/delay.h>
>  #include <linux/sched.h>
> @@ -84,15 +87,17 @@ int lbs_process_command_response(struct lbs_private *priv, u8 *data, u32 len)
>  	lbs_deb_hex(LBS_DEB_CMD, "CMD_RESP", (void *) resp, len);
>  
>  	if (resp->seqnum != priv->cur_cmd->cmdbuf->seqnum) {
> -		lbs_pr_info("Received CMD_RESP with invalid sequence %d (expected %d)\n",
> -			    le16_to_cpu(resp->seqnum), le16_to_cpu(priv->cur_cmd->cmdbuf->seqnum));
> +		pr_info("Received CMD_RESP with invalid sequence %d (expected %d)\n",
> +			le16_to_cpu(resp->seqnum),
> +			le16_to_cpu(priv->cur_cmd->cmdbuf->seqnum));
>  		spin_unlock_irqrestore(&priv->driver_lock, flags);
>  		ret = -1;
>  		goto done;
>  	}
>  	if (respcmd != CMD_RET(curcmd) &&
>  	    respcmd != CMD_RET_802_11_ASSOCIATE && curcmd != CMD_802_11_ASSOCIATE) {
> -		lbs_pr_info("Invalid CMD_RESP %x to command %x!\n", respcmd, curcmd);
> +		pr_info("Invalid CMD_RESP %x to command %x!\n",
> +			respcmd, curcmd);
>  		spin_unlock_irqrestore(&priv->driver_lock, flags);
>  		ret = -1;
>  		goto done;
> @@ -101,8 +106,8 @@ int lbs_process_command_response(struct lbs_private *priv, u8 *data, u32 len)
>  	if (resp->result == cpu_to_le16(0x0004)) {
>  		/* 0x0004 means -EAGAIN. Drop the response, let it time out
>  		   and be resubmitted */
> -		lbs_pr_info("Firmware returns DEFER to command %x. Will let it time out...\n",
> -			    le16_to_cpu(resp->command));
> +		pr_info("Firmware returns DEFER to command %x. Will let it time out...\n",
> +			le16_to_cpu(resp->command));
>  		spin_unlock_irqrestore(&priv->driver_lock, flags);
>  		ret = -1;
>  		goto done;
> @@ -313,28 +318,28 @@ int lbs_process_event(struct lbs_private *priv, u32 event)
>  		lbs_deb_cmd("EVENT: ADHOC beacon lost\n");
>  		break;
>  	case MACREG_INT_CODE_RSSI_LOW:
> -		lbs_pr_alert("EVENT: rssi low\n");
> +		pr_alert("EVENT: rssi low\n");
>  		break;
>  	case MACREG_INT_CODE_SNR_LOW:
> -		lbs_pr_alert("EVENT: snr low\n");
> +		pr_alert("EVENT: snr low\n");
>  		break;
>  	case MACREG_INT_CODE_MAX_FAIL:
> -		lbs_pr_alert("EVENT: max fail\n");
> +		pr_alert("EVENT: max fail\n");
>  		break;
>  	case MACREG_INT_CODE_RSSI_HIGH:
> -		lbs_pr_alert("EVENT: rssi high\n");
> +		pr_alert("EVENT: rssi high\n");
>  		break;
>  	case MACREG_INT_CODE_SNR_HIGH:
> -		lbs_pr_alert("EVENT: snr high\n");
> +		pr_alert("EVENT: snr high\n");
>  		break;
>  
>  	case MACREG_INT_CODE_MESH_AUTO_STARTED:
>  		/* Ignore spurious autostart events */
> -		lbs_pr_info("EVENT: MESH_AUTO_STARTED (ignoring)\n");
> +		pr_info("EVENT: MESH_AUTO_STARTED (ignoring)\n");
>  		break;
>  
>  	default:
> -		lbs_pr_alert("EVENT: unknown event id %d\n", event);
> +		pr_alert("EVENT: unknown event id %d\n", event);
>  		break;
>  	}
>  
> diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
> index fbf3b033..c179094 100644
> --- a/drivers/net/wireless/libertas/debugfs.c
> +++ b/drivers/net/wireless/libertas/debugfs.c
> @@ -1,3 +1,5 @@
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/dcache.h>
>  #include <linux/debugfs.h>
>  #include <linux/delay.h>
> @@ -151,13 +153,13 @@ static ssize_t lbs_host_sleep_write(struct file *file,
>  		ret = lbs_set_host_sleep(priv, 0);
>  	else if (host_sleep == 1) {
>  		if (priv->wol_criteria == EHS_REMOVE_WAKEUP) {
> -			lbs_pr_info("wake parameters not configured");
> +			pr_info("wake parameters not configured\n");
>  			ret = -EINVAL;
>  			goto out_unlock;
>  		}
>  		ret = lbs_set_host_sleep(priv, 1);
>  	} else {
> -		lbs_pr_err("invalid option\n");
> +		pr_err("invalid option\n");
>  		ret = -EINVAL;
>  	}
>  
> diff --git a/drivers/net/wireless/libertas/defs.h b/drivers/net/wireless/libertas/defs.h
> index d00c728..c9b89b0 100644
> --- a/drivers/net/wireless/libertas/defs.h
> +++ b/drivers/net/wireless/libertas/defs.h
> @@ -89,13 +89,6 @@ do { if ((lbs_debug & (grp)) == (grp)) \
>  #define lbs_deb_spi(fmt, args...)       LBS_DEB_LL(LBS_DEB_SPI, " spi", fmt, ##args)
>  #define lbs_deb_cfg80211(fmt, args...)  LBS_DEB_LL(LBS_DEB_CFG80211, " cfg80211", fmt, ##args)
>  
> -#define lbs_pr_info(format, args...) \
> -	printk(KERN_INFO DRV_NAME": " format, ## args)
> -#define lbs_pr_err(format, args...) \
> -	printk(KERN_ERR DRV_NAME": " format, ## args)
> -#define lbs_pr_alert(format, args...) \
> -	printk(KERN_ALERT DRV_NAME": " format, ## args)
> -
>  #ifdef DEBUG
>  static inline void lbs_deb_hex(unsigned int grp, const char *prompt, u8 *buf, int len)
>  {
> diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
> index 8712cb2..eb88d9a 100644
> --- a/drivers/net/wireless/libertas/if_cs.c
> +++ b/drivers/net/wireless/libertas/if_cs.c
> @@ -21,6 +21,8 @@
>  
>  */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/module.h>
>  #include <linux/slab.h>
>  #include <linux/delay.h>
> @@ -361,7 +363,7 @@ static int if_cs_send_cmd(struct lbs_private *priv, u8 *buf, u16 nb)
>  		if (status & IF_CS_BIT_COMMAND)
>  			break;
>  		if (++loops > 100) {
> -			lbs_pr_err("card not ready for commands\n");
> +			pr_err("card not ready for commands\n");
>  			goto done;
>  		}
>  		mdelay(1);
> @@ -431,14 +433,14 @@ static int if_cs_receive_cmdres(struct lbs_private *priv, u8 *data, u32 *len)
>  	/* is hardware ready? */
>  	status = if_cs_read16(priv->card, IF_CS_CARD_STATUS);
>  	if ((status & IF_CS_BIT_RESP) == 0) {
> -		lbs_pr_err("no cmd response in card\n");
> +		pr_err("no cmd response in card\n");
>  		*len = 0;
>  		goto out;
>  	}
>  
>  	*len = if_cs_read16(priv->card, IF_CS_RESP_LEN);
>  	if ((*len == 0) || (*len > LBS_CMD_BUFFER_SIZE)) {
> -		lbs_pr_err("card cmd buffer has invalid # of bytes (%d)\n", *len);
> +		pr_err("card cmd buffer has invalid # of bytes (%d)\n", *len);
>  		goto out;
>  	}
>  
> @@ -472,7 +474,7 @@ static struct sk_buff *if_cs_receive_data(struct lbs_private *priv)
>  
>  	len = if_cs_read16(priv->card, IF_CS_READ_LEN);
>  	if (len == 0 || len > MRVDRV_ETH_RX_PACKET_BUFFER_SIZE) {
> -		lbs_pr_err("card data buffer has invalid # of bytes (%d)\n", len);
> +		pr_err("card data buffer has invalid # of bytes (%d)\n", len);
>  		priv->dev->stats.rx_dropped++;
>  		goto dat_err;
>  	}
> @@ -644,8 +646,8 @@ static int if_cs_prog_helper(struct if_cs_card *card, const struct firmware *fw)
>  		ret = if_cs_poll_while_fw_download(card, IF_CS_CARD_STATUS,
>  			IF_CS_BIT_COMMAND);
>  		if (ret < 0) {
> -			lbs_pr_err("can't download helper at 0x%x, ret %d\n",
> -				sent, ret);
> +			pr_err("can't download helper at 0x%x, ret %d\n",
> +			       sent, ret);
>  			goto done;
>  		}
>  
> @@ -675,7 +677,7 @@ static int if_cs_prog_real(struct if_cs_card *card, const struct firmware *fw)
>  	ret = if_cs_poll_while_fw_download(card, IF_CS_SQ_READ_LOW,
>  		IF_CS_SQ_HELPER_OK);
>  	if (ret < 0) {
> -		lbs_pr_err("helper firmware doesn't answer\n");
> +		pr_err("helper firmware doesn't answer\n");
>  		goto done;
>  	}
>  
> @@ -683,13 +685,13 @@ static int if_cs_prog_real(struct if_cs_card *card, const struct firmware *fw)
>  		len = if_cs_read16(card, IF_CS_SQ_READ_LOW);
>  		if (len & 1) {
>  			retry++;
> -			lbs_pr_info("odd, need to retry this firmware block\n");
> +			pr_info("odd, need to retry this firmware block\n");
>  		} else {
>  			retry = 0;
>  		}
>  
>  		if (retry > 20) {
> -			lbs_pr_err("could not download firmware\n");
> +			pr_err("could not download firmware\n");
>  			ret = -ENODEV;
>  			goto done;
>  		}
> @@ -709,14 +711,14 @@ static int if_cs_prog_real(struct if_cs_card *card, const struct firmware *fw)
>  		ret = if_cs_poll_while_fw_download(card, IF_CS_CARD_STATUS,
>  			IF_CS_BIT_COMMAND);
>  		if (ret < 0) {
> -			lbs_pr_err("can't download firmware at 0x%x\n", sent);
> +			pr_err("can't download firmware at 0x%x\n", sent);
>  			goto done;
>  		}
>  	}
>  
>  	ret = if_cs_poll_while_fw_download(card, IF_CS_SCRATCH, 0x5a);
>  	if (ret < 0)
> -		lbs_pr_err("firmware download failed\n");
> +		pr_err("firmware download failed\n");
>  
>  done:
>  	lbs_deb_leave_args(LBS_DEB_CS, "ret %d", ret);
> @@ -750,7 +752,7 @@ static int if_cs_host_to_card(struct lbs_private *priv,
>  		ret = if_cs_send_cmd(priv, buf, nb);
>  		break;
>  	default:
> -		lbs_pr_err("%s: unsupported type %d\n", __func__, type);
> +		pr_err("%s: unsupported type %d\n", __func__, type);
>  	}
>  
>  	lbs_deb_leave_args(LBS_DEB_CS, "ret %d", ret);
> @@ -779,7 +781,7 @@ static int if_cs_ioprobe(struct pcmcia_device *p_dev, void *priv_data)
>  	p_dev->resource[0]->flags |= IO_DATA_PATH_WIDTH_AUTO;
>  
>  	if (p_dev->resource[1]->end) {
> -		lbs_pr_err("wrong CIS (check number of IO windows)\n");
> +		pr_err("wrong CIS (check number of IO windows)\n");
>  		return -ENODEV;
>  	}
>  
> @@ -800,7 +802,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
>  
>  	card = kzalloc(sizeof(struct if_cs_card), GFP_KERNEL);
>  	if (!card) {
> -		lbs_pr_err("error in kzalloc\n");
> +		pr_err("error in kzalloc\n");
>  		goto out;
>  	}
>  	card->p_dev = p_dev;
> @@ -809,7 +811,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
>  	p_dev->config_flags |= CONF_ENABLE_IRQ | CONF_AUTO_SET_IO;
>  
>  	if (pcmcia_loop_config(p_dev, if_cs_ioprobe, NULL)) {
> -		lbs_pr_err("error in pcmcia_loop_config\n");
> +		pr_err("error in pcmcia_loop_config\n");
>  		goto out1;
>  	}
>  
> @@ -825,14 +827,14 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
>  	card->iobase = ioport_map(p_dev->resource[0]->start,
>  				resource_size(p_dev->resource[0]));
>  	if (!card->iobase) {
> -		lbs_pr_err("error in ioport_map\n");
> +		pr_err("error in ioport_map\n");
>  		ret = -EIO;
>  		goto out1;
>  	}
>  
>  	ret = pcmcia_enable_device(p_dev);
>  	if (ret) {
> -		lbs_pr_err("error in pcmcia_enable_device\n");
> +		pr_err("error in pcmcia_enable_device\n");
>  		goto out2;
>  	}
>  
> @@ -847,8 +849,8 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
>  
>  	card->model = get_model(p_dev->manf_id, p_dev->card_id);
>  	if (card->model == MODEL_UNKNOWN) {
> -		lbs_pr_err("unsupported manf_id 0x%04x / card_id 0x%04x\n",
> -			   p_dev->manf_id, p_dev->card_id);
> +		pr_err("unsupported manf_id 0x%04x / card_id 0x%04x\n",
> +		       p_dev->manf_id, p_dev->card_id);
>  		goto out2;
>  	}
>  
> @@ -857,20 +859,20 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
>  	if (card->model == MODEL_8305) {
>  		card->align_regs = 1;
>  		if (prod_id < IF_CS_CF8305_B1_REV) {
> -			lbs_pr_err("8305 rev B0 and older are not supported\n");
> +			pr_err("8305 rev B0 and older are not supported\n");
>  			ret = -ENODEV;
>  			goto out2;
>  		}
>  	}
>  
>  	if ((card->model == MODEL_8381) && prod_id < IF_CS_CF8381_B3_REV) {
> -		lbs_pr_err("8381 rev B2 and older are not supported\n");
> +		pr_err("8381 rev B2 and older are not supported\n");
>  		ret = -ENODEV;
>  		goto out2;
>  	}
>  
>  	if ((card->model == MODEL_8385) && prod_id < IF_CS_CF8385_B1_REV) {
> -		lbs_pr_err("8385 rev B0 and older are not supported\n");
> +		pr_err("8385 rev B0 and older are not supported\n");
>  		ret = -ENODEV;
>  		goto out2;
>  	}
> @@ -878,7 +880,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
>  	ret = lbs_get_firmware(&p_dev->dev, NULL, NULL, card->model,
>  				&fw_table[0], &helper, &mainfw);
>  	if (ret) {
> -		lbs_pr_err("failed to find firmware (%d)\n", ret);
> +		pr_err("failed to find firmware (%d)\n", ret);
>  		goto out2;
>  	}
>  
> @@ -909,7 +911,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
>  	ret = request_irq(p_dev->irq, if_cs_interrupt,
>  		IRQF_SHARED, DRV_NAME, card);
>  	if (ret) {
> -		lbs_pr_err("error in request_irq\n");
> +		pr_err("error in request_irq\n");
>  		goto out3;
>  	}
>  
> @@ -920,7 +922,7 @@ static int if_cs_probe(struct pcmcia_device *p_dev)
>  
>  	/* And finally bring the card up */
>  	if (lbs_start_card(priv) != 0) {
> -		lbs_pr_err("could not activate card\n");
> +		pr_err("could not activate card\n");
>  		goto out3;
>  	}
>  
> diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
> index b4de0ca..ab86779 100644
> --- a/drivers/net/wireless/libertas/if_sdio.c
> +++ b/drivers/net/wireless/libertas/if_sdio.c
> @@ -26,6 +26,8 @@
>   * if_sdio_card_to_host() to pad the data.
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/kernel.h>
>  #include <linux/moduleparam.h>
>  #include <linux/slab.h>
> @@ -409,7 +411,7 @@ static int if_sdio_card_to_host(struct if_sdio_card *card)
>  
>  out:
>  	if (ret)
> -		lbs_pr_err("problem fetching packet from firmware\n");
> +		pr_err("problem fetching packet from firmware\n");
>  
>  	lbs_deb_leave_args(LBS_DEB_SDIO, "ret %d", ret);
>  
> @@ -446,7 +448,7 @@ static void if_sdio_host_to_card_worker(struct work_struct *work)
>  		}
>  
>  		if (ret)
> -			lbs_pr_err("error %d sending packet to firmware\n", ret);
> +			pr_err("error %d sending packet to firmware\n", ret);
>  
>  		sdio_release_host(card->func);
>  
> @@ -555,7 +557,7 @@ release:
>  
>  out:
>  	if (ret)
> -		lbs_pr_err("failed to load helper firmware\n");
> +		pr_err("failed to load helper firmware\n");
>  
>  	lbs_deb_leave_args(LBS_DEB_SDIO, "ret %d", ret);
>  	return ret;
> @@ -669,7 +671,7 @@ release:
>  
>  out:
>  	if (ret)
> -		lbs_pr_err("failed to load firmware\n");
> +		pr_err("failed to load firmware\n");
>  
>  	lbs_deb_leave_args(LBS_DEB_SDIO, "ret %d", ret);
>  	return ret;
> @@ -723,7 +725,7 @@ static int if_sdio_prog_firmware(struct if_sdio_card *card)
>  	ret = lbs_get_firmware(&card->func->dev, lbs_helper_name, lbs_fw_name,
>  				card->model, &fw_table[0], &helper, &mainfw);
>  	if (ret) {
> -		lbs_pr_err("failed to find firmware (%d)\n", ret);
> +		pr_err("failed to find firmware (%d)\n", ret);
>  		goto out;
>  	}
>  
> @@ -849,7 +851,7 @@ static int if_sdio_enter_deep_sleep(struct lbs_private *priv)
>  	ret = __lbs_cmd(priv, CMD_802_11_DEEP_SLEEP, &cmd, sizeof(cmd),
>  			lbs_cmd_copyback, (unsigned long) &cmd);
>  	if (ret)
> -		lbs_pr_err("DEEP_SLEEP cmd failed\n");
> +		pr_err("DEEP_SLEEP cmd failed\n");
>  
>  	mdelay(200);
>  	return ret;
> @@ -865,7 +867,7 @@ static int if_sdio_exit_deep_sleep(struct lbs_private *priv)
>  
>  	sdio_writeb(card->func, HOST_POWER_UP, CONFIGURATION_REG, &ret);
>  	if (ret)
> -		lbs_pr_err("sdio_writeb failed!\n");
> +		pr_err("sdio_writeb failed!\n");
>  
>  	sdio_release_host(card->func);
>  	lbs_deb_leave_args(LBS_DEB_SDIO, "ret %d", ret);
> @@ -882,7 +884,7 @@ static int if_sdio_reset_deep_sleep_wakeup(struct lbs_private *priv)
>  
>  	sdio_writeb(card->func, 0, CONFIGURATION_REG, &ret);
>  	if (ret)
> -		lbs_pr_err("sdio_writeb failed!\n");
> +		pr_err("sdio_writeb failed!\n");
>  
>  	sdio_release_host(card->func);
>  	lbs_deb_leave_args(LBS_DEB_SDIO, "ret %d", ret);
> @@ -961,7 +963,7 @@ static int if_sdio_probe(struct sdio_func *func,
>  	}
>  
>  	if (i == func->card->num_info) {
> -		lbs_pr_err("unable to identify card model\n");
> +		pr_err("unable to identify card model\n");
>  		return -ENODEV;
>  	}
>  
> @@ -995,7 +997,7 @@ static int if_sdio_probe(struct sdio_func *func,
>  			break;
>  	}
>  	if (i == ARRAY_SIZE(fw_table)) {
> -		lbs_pr_err("unknown card model 0x%x\n", card->model);
> +		pr_err("unknown card model 0x%x\n", card->model);
>  		ret = -ENODEV;
>  		goto free;
>  	}
> @@ -1101,7 +1103,7 @@ static int if_sdio_probe(struct sdio_func *func,
>  		lbs_deb_sdio("send function INIT command\n");
>  		if (__lbs_cmd(priv, CMD_FUNC_INIT, &cmd, sizeof(cmd),
>  				lbs_cmd_copyback, (unsigned long) &cmd))
> -			lbs_pr_alert("CMD_FUNC_INIT cmd failed\n");
> +			pr_alert("CMD_FUNC_INIT cmd failed\n");
>  	}
>  
>  	ret = lbs_start_card(priv);
> @@ -1163,7 +1165,7 @@ static void if_sdio_remove(struct sdio_func *func)
>  		if (__lbs_cmd(card->priv, CMD_FUNC_SHUTDOWN,
>  				&cmd, sizeof(cmd), lbs_cmd_copyback,
>  				(unsigned long) &cmd))
> -			lbs_pr_alert("CMD_FUNC_SHUTDOWN cmd failed\n");
> +			pr_alert("CMD_FUNC_SHUTDOWN cmd failed\n");
>  	}
>  
> 
> @@ -1202,21 +1204,19 @@ static int if_sdio_suspend(struct device *dev)
>  
>  	mmc_pm_flag_t flags = sdio_get_host_pm_caps(func);
>  
> -	lbs_pr_info("%s: suspend: PM flags = 0x%x\n",
> -						sdio_func_id(func), flags);
> +	pr_info("%s: suspend: PM flags = 0x%x\n", sdio_func_id(func), flags);
>  
>  	/* If we aren't being asked to wake on anything, we should bail out
>  	 * and let the SD stack power down the card.
>  	 */
>  	if (card->priv->wol_criteria == EHS_REMOVE_WAKEUP) {
> -		lbs_pr_info("Suspend without wake params -- "
> -						"powering down card.");
> +		pr_info("Suspend without wake params -- powering down card\n");
>  		return -ENOSYS;
>  	}
>  
>  	if (!(flags & MMC_PM_KEEP_POWER)) {
> -		lbs_pr_err("%s: cannot remain alive while host is suspended\n",
> -			sdio_func_id(func));
> +		pr_err("%s: cannot remain alive while host is suspended\n",
> +		       sdio_func_id(func));
>  		return -ENOSYS;
>  	}
>  
> @@ -1237,7 +1237,7 @@ static int if_sdio_resume(struct device *dev)
>  	struct if_sdio_card *card = sdio_get_drvdata(func);
>  	int ret;
>  
> -	lbs_pr_info("%s: resume: we're back\n", sdio_func_id(func));
> +	pr_info("%s: resume: we're back\n", sdio_func_id(func));
>  
>  	ret = lbs_resume(card->priv);
>  
> diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
> index 078ef43..bebd9f0 100644
> --- a/drivers/net/wireless/libertas/if_spi.c
> +++ b/drivers/net/wireless/libertas/if_spi.c
> @@ -17,6 +17,8 @@
>   * (at your option) any later version.
>   */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/moduleparam.h>
>  #include <linux/firmware.h>
>  #include <linux/jiffies.h>
> @@ -297,8 +299,7 @@ static int spu_wait_for_u16(struct if_spi_card *card, u16 reg,
>  		}
>  		udelay(100);
>  		if (time_after(jiffies, timeout)) {
> -			lbs_pr_err("%s: timeout with val=%02x, "
> -			       "target_mask=%02x, target=%02x\n",
> +			pr_err("%s: timeout with val=%02x, target_mask=%02x, target=%02x\n",
>  			       __func__, val, target_mask, target);
>  			return -ETIMEDOUT;
>  		}
> @@ -391,7 +392,7 @@ static int spu_set_bus_mode(struct if_spi_card *card, u16 mode)
>  	if (err)
>  		return err;
>  	if ((rval & 0xF) != mode) {
> -		lbs_pr_err("Can't read bus mode register.\n");
> +		pr_err("Can't read bus mode register\n");
>  		return -EIO;
>  	}
>  	return 0;
> @@ -512,7 +513,7 @@ static int if_spi_prog_helper_firmware(struct if_spi_card *card,
>  
>  out:
>  	if (err)
> -		lbs_pr_err("failed to load helper firmware (err=%d)\n", err);
> +		pr_err("failed to load helper firmware (err=%d)\n", err);
>  	lbs_deb_leave_args(LBS_DEB_SPI, "err %d", err);
>  	return err;
>  }
> @@ -531,7 +532,7 @@ static int if_spi_prog_main_firmware_check_len(struct if_spi_card *card,
>  				IF_SPI_HIST_CMD_DOWNLOAD_RDY,
>  				IF_SPI_HIST_CMD_DOWNLOAD_RDY);
>  	if (err) {
> -		lbs_pr_err("timed out waiting for host_int_status\n");
> +		pr_err("timed out waiting for host_int_status\n");
>  		return err;
>  	}
>  
> @@ -541,9 +542,8 @@ static int if_spi_prog_main_firmware_check_len(struct if_spi_card *card,
>  		return err;
>  
>  	if (len > IF_SPI_CMD_BUF_SIZE) {
> -		lbs_pr_err("firmware load device requested a larger "
> -			   "tranfer than we are prepared to "
> -			   "handle. (len = %d)\n", len);
> +		pr_err("firmware load device requested a larger transfer than we are prepared to handle (len = %d)\n",
> +		       len);
>  		return -EIO;
>  	}
>  	if (len & 0x1) {
> @@ -572,8 +572,8 @@ static int if_spi_prog_main_firmware(struct if_spi_card *card,
>  
>  	err = spu_wait_for_u16(card, IF_SPI_SCRATCH_1_REG, 0, 0);
>  	if (err) {
> -		lbs_pr_err("%s: timed out waiting for initial "
> -			   "scratch reg = 0\n", __func__);
> +		pr_err("%s: timed out waiting for initial scratch reg = 0\n",
> +		       __func__);
>  		goto out;
>  	}
>  
> @@ -589,15 +589,13 @@ static int if_spi_prog_main_firmware(struct if_spi_card *card,
>  		if (bytes < 0) {
>  			/* If there are no more bytes left, we would normally
>  			 * expect to have terminated with len = 0 */
> -			lbs_pr_err("Firmware load wants more bytes "
> -				   "than we have to offer.\n");
> +			pr_err("Firmware load wants more bytes than we have to offer\n");
>  			break;
>  		}
>  		if (crc_err) {
>  			/* Previous transfer failed. */
>  			if (++num_crc_errs > MAX_MAIN_FW_LOAD_CRC_ERR) {
> -				lbs_pr_err("Too many CRC errors encountered "
> -					   "in firmware load.\n");
> +				pr_err("Too many CRC errors encountered in firmware load\n");
>  				err = -EIO;
>  				goto out;
>  			}
> @@ -626,21 +624,20 @@ static int if_spi_prog_main_firmware(struct if_spi_card *card,
>  		prev_len = len;
>  	}
>  	if (bytes > prev_len) {
> -		lbs_pr_err("firmware load wants fewer bytes than "
> -			   "we have to offer.\n");
> +		pr_err("firmware load wants fewer bytes than we have to offer\n");
>  	}
>  
>  	/* Confirm firmware download */
>  	err = spu_wait_for_u32(card, IF_SPI_SCRATCH_4_REG,
>  					SUCCESSFUL_FW_DOWNLOAD_MAGIC);
>  	if (err) {
> -		lbs_pr_err("failed to confirm the firmware download\n");
> +		pr_err("failed to confirm the firmware download\n");
>  		goto out;
>  	}
>  
>  out:
>  	if (err)
> -		lbs_pr_err("failed to load firmware (err=%d)\n", err);
> +		pr_err("failed to load firmware (err=%d)\n", err);
>  	lbs_deb_leave_args(LBS_DEB_SPI, "err %d", err);
>  	return err;
>  }
> @@ -677,14 +674,12 @@ static int if_spi_c2h_cmd(struct if_spi_card *card)
>  	if (err)
>  		goto out;
>  	if (!len) {
> -		lbs_pr_err("%s: error: card has no data for host\n",
> -			   __func__);
> +		pr_err("%s: error: card has no data for host\n", __func__);
>  		err = -EINVAL;
>  		goto out;
>  	} else if (len > IF_SPI_CMD_BUF_SIZE) {
> -		lbs_pr_err("%s: error: response packet too large: "
> -			   "%d bytes, but maximum is %d\n",
> -			   __func__, len, IF_SPI_CMD_BUF_SIZE);
> +		pr_err("%s: error: response packet too large: %d bytes, but maximum is %d\n",
> +		       __func__, len, IF_SPI_CMD_BUF_SIZE);
>  		err = -EINVAL;
>  		goto out;
>  	}
> @@ -705,7 +700,7 @@ static int if_spi_c2h_cmd(struct if_spi_card *card)
>  
>  out:
>  	if (err)
> -		lbs_pr_err("%s: err=%d\n", __func__, err);
> +		pr_err("%s: err=%d\n", __func__, err);
>  	lbs_deb_leave(LBS_DEB_SPI);
>  	return err;
>  }
> @@ -725,14 +720,12 @@ static int if_spi_c2h_data(struct if_spi_card *card)
>  	if (err)
>  		goto out;
>  	if (!len) {
> -		lbs_pr_err("%s: error: card has no data for host\n",
> -			   __func__);
> +		pr_err("%s: error: card has no data for host\n", __func__);
>  		err = -EINVAL;
>  		goto out;
>  	} else if (len > MRVDRV_ETH_RX_PACKET_BUFFER_SIZE) {
> -		lbs_pr_err("%s: error: card has %d bytes of data, but "
> -			   "our maximum skb size is %zu\n",
> -			   __func__, len, MRVDRV_ETH_RX_PACKET_BUFFER_SIZE);
> +		pr_err("%s: error: card has %d bytes of data, but our maximum skb size is %zu\n",
> +		       __func__, len, MRVDRV_ETH_RX_PACKET_BUFFER_SIZE);
>  		err = -EINVAL;
>  		goto out;
>  	}
> @@ -763,7 +756,7 @@ free_skb:
>  	dev_kfree_skb(skb);
>  out:
>  	if (err)
> -		lbs_pr_err("%s: err=%d\n", __func__, err);
> +		pr_err("%s: err=%d\n", __func__, err);
>  	lbs_deb_leave(LBS_DEB_SPI);
>  	return err;
>  }
> @@ -785,7 +778,7 @@ static void if_spi_h2c(struct if_spi_card *card,
>  		port_reg = IF_SPI_CMD_RDWRPORT_REG;
>  		break;
>  	default:
> -		lbs_pr_err("can't transfer buffer of type %d\n", type);
> +		pr_err("can't transfer buffer of type %d\n", type);
>  		err = -EINVAL;
>  		goto out;
>  	}
> @@ -799,7 +792,7 @@ out:
>  	kfree(packet);
>  
>  	if (err)
> -		lbs_pr_err("%s: error %d\n", __func__, err);
> +		pr_err("%s: error %d\n", __func__, err);
>  }
>  
>  /* Inform the host about a card event */
> @@ -823,7 +816,7 @@ static void if_spi_e2h(struct if_spi_card *card)
>  	lbs_queue_event(priv, cause & 0xff);
>  out:
>  	if (err)
> -		lbs_pr_err("%s: error %d\n", __func__, err);
> +		pr_err("%s: error %d\n", __func__, err);
>  }
>  
>  static void if_spi_host_to_card_worker(struct work_struct *work)
> @@ -843,7 +836,7 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
>  	err = spu_read_u16(card, IF_SPI_HOST_INT_STATUS_REG,
>  				&hiStatus);
>  	if (err) {
> -		lbs_pr_err("I/O error\n");
> +		pr_err("I/O error\n");
>  		goto err;
>  	}
>  
> @@ -905,7 +898,7 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
>  
>  err:
>  	if (err)
> -		lbs_pr_err("%s: got error %d\n", __func__, err);
> +		pr_err("%s: got error %d\n", __func__, err);
>  
>  	lbs_deb_leave(LBS_DEB_SPI);
>  }
> @@ -927,7 +920,7 @@ static int if_spi_host_to_card(struct lbs_private *priv,
>  	lbs_deb_enter_args(LBS_DEB_SPI, "type %d, bytes %d", type, nb);
>  
>  	if (nb == 0) {
> -		lbs_pr_err("%s: invalid size requested: %d\n", __func__, nb);
> +		pr_err("%s: invalid size requested: %d\n", __func__, nb);
>  		err = -EINVAL;
>  		goto out;
>  	}
> @@ -955,7 +948,7 @@ static int if_spi_host_to_card(struct lbs_private *priv,
>  		spin_unlock_irqrestore(&card->buffer_lock, flags);
>  		break;
>  	default:
> -		lbs_pr_err("can't transfer buffer of type %d", type);
> +		pr_err("can't transfer buffer of type %d\n", type);
>  		err = -EINVAL;
>  		break;
>  	}
> @@ -1016,8 +1009,7 @@ static int if_spi_init_card(struct if_spi_card *card)
>  				break;
>  		}
>  		if (i == ARRAY_SIZE(fw_table)) {
> -			lbs_pr_err("Unsupported chip_id: 0x%02x\n",
> -					card->card_id);
> +			pr_err("Unsupported chip_id: 0x%02x\n", card->card_id);
>  			err = -ENODEV;
>  			goto out;
>  		}
> @@ -1026,7 +1018,7 @@ static int if_spi_init_card(struct if_spi_card *card)
>  					card->card_id, &fw_table[0], &helper,
>  					&mainfw);
>  		if (err) {
> -			lbs_pr_err("failed to find firmware (%d)\n", err);
> +			pr_err("failed to find firmware (%d)\n", err);
>  			goto out;
>  		}
>  
> @@ -1149,7 +1141,7 @@ static int __devinit if_spi_probe(struct spi_device *spi)
>  	err = request_irq(spi->irq, if_spi_host_interrupt,
>  			IRQF_TRIGGER_FALLING, "libertas_spi", card);
>  	if (err) {
> -		lbs_pr_err("can't get host irq line-- request_irq failed\n");
> +		pr_err("can't get host irq line-- request_irq failed\n");
>  		goto terminate_workqueue;
>  	}
>  
> diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
> index 6524c70..7260791 100644
> --- a/drivers/net/wireless/libertas/if_usb.c
> +++ b/drivers/net/wireless/libertas/if_usb.c
> @@ -1,6 +1,9 @@
>  /**
>    * This file contains functions used in USB interface module.
>    */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/delay.h>
>  #include <linux/moduleparam.h>
>  #include <linux/firmware.h>
> @@ -145,7 +148,7 @@ static void if_usb_write_bulk_callback(struct urb *urb)
>  			lbs_host_to_card_done(priv);
>  	} else {
>  		/* print the failure status number for debug */
> -		lbs_pr_info("URB in failure status: %d\n", urb->status);
> +		pr_info("URB in failure status: %d\n", urb->status);
>  	}
>  }
>  
> @@ -195,7 +198,7 @@ static void if_usb_setup_firmware(struct lbs_private *priv)
>  	wake_method.hdr.size = cpu_to_le16(sizeof(wake_method));
>  	wake_method.action = cpu_to_le16(CMD_ACT_GET);
>  	if (lbs_cmd_with_response(priv, CMD_802_11_FW_WAKE_METHOD, &wake_method)) {
> -		lbs_pr_info("Firmware does not seem to support PS mode\n");
> +		pr_info("Firmware does not seem to support PS mode\n");
>  		priv->fwcapinfo &= ~FW_CAPINFO_PS;
>  	} else {
>  		if (le16_to_cpu(wake_method.method) == CMD_WAKE_METHOD_COMMAND_INT) {
> @@ -204,7 +207,7 @@ static void if_usb_setup_firmware(struct lbs_private *priv)
>  			/* The versions which boot up this way don't seem to
>  			   work even if we set it to the command interrupt */
>  			priv->fwcapinfo &= ~FW_CAPINFO_PS;
> -			lbs_pr_info("Firmware doesn't wake via command interrupt; disabling PS mode\n");
> +			pr_info("Firmware doesn't wake via command interrupt; disabling PS mode\n");
>  		}
>  	}
>  }
> @@ -216,7 +219,7 @@ static void if_usb_fw_timeo(unsigned long priv)
>  	if (cardp->fwdnldover) {
>  		lbs_deb_usb("Download complete, no event. Assuming success\n");
>  	} else {
> -		lbs_pr_err("Download timed out\n");
> +		pr_err("Download timed out\n");
>  		cardp->surprise_removed = 1;
>  	}
>  	wake_up(&cardp->fw_wq);
> @@ -250,7 +253,7 @@ static int if_usb_probe(struct usb_interface *intf,
>  
>  	cardp = kzalloc(sizeof(struct if_usb_card), GFP_KERNEL);
>  	if (!cardp) {
> -		lbs_pr_err("Out of memory allocating private data.\n");
> +		pr_err("Out of memory allocating private data\n");
>  		goto error;
>  	}
>  
> @@ -340,10 +343,10 @@ static int if_usb_probe(struct usb_interface *intf,
>  	usb_set_intfdata(intf, cardp);
>  
>  	if (device_create_file(&priv->dev->dev, &dev_attr_lbs_flash_fw))
> -		lbs_pr_err("cannot register lbs_flash_fw attribute\n");
> +		pr_err("cannot register lbs_flash_fw attribute\n");
>  
>  	if (device_create_file(&priv->dev->dev, &dev_attr_lbs_flash_boot2))
> -		lbs_pr_err("cannot register lbs_flash_boot2 attribute\n");
> +		pr_err("cannot register lbs_flash_boot2 attribute\n");
>  
>  	/*
>  	 * EHS_REMOVE_WAKEUP is not supported on all versions of the firmware.
> @@ -528,7 +531,7 @@ static int __if_usb_submit_rx_urb(struct if_usb_card *cardp,
>  	int ret = -1;
>  
>  	if (!(skb = dev_alloc_skb(MRVDRV_ETH_RX_PACKET_BUFFER_SIZE))) {
> -		lbs_pr_err("No free skb\n");
> +		pr_err("No free skb\n");
>  		goto rx_ret;
>  	}
>  
> @@ -587,7 +590,7 @@ static void if_usb_receive_fwload(struct urb *urb)
>  
>  		if (tmp[0] == cpu_to_le32(CMD_TYPE_INDICATION) &&
>  		    tmp[1] == cpu_to_le32(MACREG_INT_CODE_FIRMWARE_READY)) {
> -			lbs_pr_info("Firmware ready event received\n");
> +			pr_info("Firmware ready event received\n");
>  			wake_up(&cardp->fw_wq);
>  		} else {
>  			lbs_deb_usb("Waiting for confirmation; got %x %x\n",
> @@ -614,20 +617,20 @@ static void if_usb_receive_fwload(struct urb *urb)
>  			    bootcmdresp.magic == cpu_to_le32(CMD_TYPE_DATA) ||
>  			    bootcmdresp.magic == cpu_to_le32(CMD_TYPE_INDICATION)) {
>  				if (!cardp->bootcmdresp)
> -					lbs_pr_info("Firmware already seems alive; resetting\n");
> +					pr_info("Firmware already seems alive; resetting\n");
>  				cardp->bootcmdresp = -1;
>  			} else {
> -				lbs_pr_info("boot cmd response wrong magic number (0x%x)\n",
> +				pr_info("boot cmd response wrong magic number (0x%x)\n",
>  					    le32_to_cpu(bootcmdresp.magic));
>  			}
>  		} else if ((bootcmdresp.cmd != BOOT_CMD_FW_BY_USB) &&
>  			   (bootcmdresp.cmd != BOOT_CMD_UPDATE_FW) &&
>  			   (bootcmdresp.cmd != BOOT_CMD_UPDATE_BOOT2)) {
> -			lbs_pr_info("boot cmd response cmd_tag error (%d)\n",
> -				    bootcmdresp.cmd);
> +			pr_info("boot cmd response cmd_tag error (%d)\n",
> +				bootcmdresp.cmd);
>  		} else if (bootcmdresp.result != BOOT_CMD_RESP_OK) {
> -			lbs_pr_info("boot cmd response result error (%d)\n",
> -				    bootcmdresp.result);
> +			pr_info("boot cmd response result error (%d)\n",
> +				bootcmdresp.result);
>  		} else {
>  			cardp->bootcmdresp = 1;
>  			lbs_deb_usbd(&cardp->udev->dev,
> @@ -892,7 +895,7 @@ static int check_fwfile_format(const uint8_t *data, uint32_t totlen)
>  	} while (!exit);
>  
>  	if (ret)
> -		lbs_pr_err("firmware file format check FAIL\n");
> +		pr_err("firmware file format check FAIL\n");
>  	else
>  		lbs_deb_fw("firmware file format check PASS\n");
>  
> @@ -989,7 +992,7 @@ static int __if_usb_prog_firmware(struct if_usb_card *cardp,
>  
>  	ret = get_fw(cardp, fwname);
>  	if (ret) {
> -		lbs_pr_err("failed to find firmware (%d)\n", ret);
> +		pr_err("failed to find firmware (%d)\n", ret);
>  		goto done;
>  	}
>  
> @@ -1064,13 +1067,13 @@ restart:
>  	usb_kill_urb(cardp->rx_urb);
>  
>  	if (!cardp->fwdnldover) {
> -		lbs_pr_info("failed to load fw, resetting device!\n");
> +		pr_info("failed to load fw, resetting device!\n");
>  		if (--reset_count >= 0) {
>  			if_usb_reset_device(cardp);
>  			goto restart;
>  		}
>  
> -		lbs_pr_info("FW download failure, time = %d ms\n", i * 100);
> +		pr_info("FW download failure, time = %d ms\n", i * 100);
>  		ret = -EIO;
>  		goto release_fw;
>  	}
> diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
> index ca8149c..639461b 100644
> --- a/drivers/net/wireless/libertas/main.c
> +++ b/drivers/net/wireless/libertas/main.c
> @@ -4,6 +4,8 @@
>    * thread etc..
>    */
>  
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/moduleparam.h>
>  #include <linux/delay.h>
>  #include <linux/etherdevice.h>
> @@ -153,7 +155,7 @@ static void lbs_tx_timeout(struct net_device *dev)
>  
>  	lbs_deb_enter(LBS_DEB_TX);
>  
> -	lbs_pr_err("tx watch dog timeout\n");
> +	pr_err("tx watch dog timeout\n");
>  
>  	dev->trans_start = jiffies; /* prevent tx timeout */
>  
> @@ -462,7 +464,7 @@ static int lbs_thread(void *data)
>  		if (priv->cmd_timed_out && priv->cur_cmd) {
>  			struct cmd_ctrl_node *cmdnode = priv->cur_cmd;
>  
> -			lbs_pr_info("Timeout submitting command 0x%04x\n",
> +			pr_info("Timeout submitting command 0x%04x\n",
>  				le16_to_cpu(cmdnode->cmdbuf->command));
>  			lbs_complete_command(priv, cmdnode, -ETIMEDOUT);
>  			if (priv->reset_card)
> @@ -490,8 +492,7 @@ static int lbs_thread(void *data)
>  				 * after firmware fixes it
>  				 */
>  				priv->psstate = PS_STATE_AWAKE;
> -				lbs_pr_alert("ignore PS_SleepConfirm in "
> -					"non-connected state\n");
> +				pr_alert("ignore PS_SleepConfirm in non-connected state\n");
>  			}
>  		}
>  
> @@ -585,7 +586,7 @@ int lbs_suspend(struct lbs_private *priv)
>  	if (priv->is_deep_sleep) {
>  		ret = lbs_set_deep_sleep(priv, 0);
>  		if (ret) {
> -			lbs_pr_err("deep sleep cancellation failed: %d\n", ret);
> +			pr_err("deep sleep cancellation failed: %d\n", ret);
>  			return ret;
>  		}
>  		priv->deep_sleep_required = 1;
> @@ -618,7 +619,7 @@ int lbs_resume(struct lbs_private *priv)
>  		priv->deep_sleep_required = 0;
>  		ret = lbs_set_deep_sleep(priv, 1);
>  		if (ret)
> -			lbs_pr_err("deep sleep activation failed: %d\n", ret);
> +			pr_err("deep sleep activation failed: %d\n", ret);
>  	}
>  
>  	if (priv->setup_fw_on_resume)
> @@ -644,7 +645,7 @@ static void lbs_cmd_timeout_handler(unsigned long data)
>  	if (!priv->cur_cmd)
>  		goto out;
>  
> -	lbs_pr_info("command 0x%04x timed out\n",
> +	pr_info("command 0x%04x timed out\n",
>  		le16_to_cpu(priv->cur_cmd->cmdbuf->command));
>  
>  	priv->cmd_timed_out = 1;
> @@ -748,7 +749,7 @@ static int lbs_init_adapter(struct lbs_private *priv)
>  
>  	/* Allocate the command buffers */
>  	if (lbs_allocate_cmd_buffer(priv)) {
> -		lbs_pr_err("Out of memory allocating command buffers\n");
> +		pr_err("Out of memory allocating command buffers\n");
>  		ret = -ENOMEM;
>  		goto out;
>  	}
> @@ -758,7 +759,7 @@ static int lbs_init_adapter(struct lbs_private *priv)
>  	/* Create the event FIFO */
>  	ret = kfifo_alloc(&priv->event_fifo, sizeof(u32) * 16, GFP_KERNEL);
>  	if (ret) {
> -		lbs_pr_err("Out of memory allocating event FIFO buffer\n");
> +		pr_err("Out of memory allocating event FIFO buffer\n");
>  		goto out;
>  	}
>  
> @@ -809,7 +810,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
>  	/* Allocate an Ethernet device and register it */
>  	wdev = lbs_cfg_alloc(dmdev);
>  	if (IS_ERR(wdev)) {
> -		lbs_pr_err("cfg80211 init failed\n");
> +		pr_err("cfg80211 init failed\n");
>  		goto done;
>  	}
>  
> @@ -818,7 +819,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
>  	priv->wdev = wdev;
>  
>  	if (lbs_init_adapter(priv)) {
> -		lbs_pr_err("failed to initialize adapter structure.\n");
> +		pr_err("failed to initialize adapter structure\n");
>  		goto err_wdev;
>  	}
>  
> @@ -950,7 +951,7 @@ int lbs_start_card(struct lbs_private *priv)
>  		goto done;
>  
>  	if (lbs_cfg_register(priv)) {
> -		lbs_pr_err("cannot register device\n");
> +		pr_err("cannot register device\n");
>  		goto done;
>  	}
>  
> @@ -960,7 +961,7 @@ int lbs_start_card(struct lbs_private *priv)
>  
>  	lbs_debugfs_init_one(priv, dev);
>  
> -	lbs_pr_info("%s: Marvell WLAN 802.11 adapter\n", dev->name);
> +	pr_info("%s: Marvell WLAN 802.11 adapter\n", dev->name);
>  
>  	ret = 0;
>  
> @@ -1087,16 +1088,14 @@ int lbs_get_firmware(struct device *dev, const char *user_helper,
>  	if (user_helper) {
>  		ret = request_firmware(helper, user_helper, dev);
>  		if (ret) {
> -			lbs_pr_err("couldn't find helper firmware %s",
> -					user_helper);
> +			pr_err("couldn't find helper firmware %s", user_helper);
>  			goto fail;
>  		}
>  	}
>  	if (user_mainfw) {
>  		ret = request_firmware(mainfw, user_mainfw, dev);
>  		if (ret) {
> -			lbs_pr_err("couldn't find main firmware %s",
> -					user_mainfw);
> +			pr_err("couldn't find main firmware %s", user_mainfw);
>  			goto fail;
>  		}
>  	}
> diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
> index 9d097b9..f7c51cb 100644
> --- a/drivers/net/wireless/libertas/mesh.c
> +++ b/drivers/net/wireless/libertas/mesh.c
> @@ -1,3 +1,5 @@
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/delay.h>
>  #include <linux/etherdevice.h>
>  #include <linux/netdevice.h>
> @@ -246,7 +248,7 @@ int lbs_init_mesh(struct lbs_private *priv)
>  		lbs_add_mesh(priv);
>  
>  		if (device_create_file(&dev->dev, &dev_attr_lbs_mesh))
> -			lbs_pr_err("cannot register lbs_mesh attribute\n");
> +			pr_err("cannot register lbs_mesh attribute\n");
>  
>  		ret = 1;
>  	}
> @@ -374,7 +376,7 @@ int lbs_add_mesh(struct lbs_private *priv)
>  	/* Register virtual mesh interface */
>  	ret = register_netdev(mesh_dev);
>  	if (ret) {
> -		lbs_pr_err("cannot register mshX virtual interface\n");
> +		pr_err("cannot register mshX virtual interface\n");
>  		goto err_free;
>  	}
>  
> @@ -926,7 +928,7 @@ static ssize_t mesh_id_get(struct device *dev, struct device_attribute *attr,
>  		return ret;
>  
>  	if (defs.meshie.val.mesh_id_len > IEEE80211_MAX_SSID_LEN) {
> -		lbs_pr_err("inconsistent mesh ID length");
> +		pr_err("inconsistent mesh ID length\n");
>  		defs.meshie.val.mesh_id_len = IEEE80211_MAX_SSID_LEN;
>  	}
>  
> diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
> index a2b1df2..fd045aa 100644
> --- a/drivers/net/wireless/libertas/rx.c
> +++ b/drivers/net/wireless/libertas/rx.c
> @@ -1,6 +1,9 @@
>  /**
>    * This file contains the handling of RX in wlan driver.
>    */
> +
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +
>  #include <linux/etherdevice.h>
>  #include <linux/slab.h>
>  #include <linux/types.h>
> @@ -191,7 +194,7 @@ static u8 convert_mv_rate_to_radiotap(u8 rate)
>  	case 12:		/*  54 Mbps */
>  		return 108;
>  	}
> -	lbs_pr_alert("Invalid Marvell WLAN rate %i\n", rate);
> +	pr_alert("Invalid Marvell WLAN rate %i\n", rate);
>  	return 0;
>  }
>  
> @@ -248,7 +251,7 @@ static int process_rxed_802_11_packet(struct lbs_private *priv,
>  	/* add space for the new radio header */
>  	if ((skb_headroom(skb) < sizeof(struct rx_radiotap_hdr)) &&
>  	    pskb_expand_head(skb, sizeof(struct rx_radiotap_hdr), 0, GFP_ATOMIC)) {
> -		lbs_pr_alert("%s: couldn't pskb_expand_head\n", __func__);
> +		pr_alert("%s: couldn't pskb_expand_head\n", __func__);
>  		ret = -ENOMEM;
>  		kfree_skb(skb);
>  		goto done;
