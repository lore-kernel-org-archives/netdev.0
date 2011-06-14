From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH net-next 2/2] drivers/net: Remove casts of void *
Date: Tue, 14 Jun 2011 11:31:45 -0700
Message-ID: <f841e39b-8c30-4c3b-9d17-fa45b6615c23@exht2.ad.emulex.com>
References: <cover.1308024069.git.joe@perches.com>
 <486a21b708a9dce0c1c0059a21a2f9b66dac9e3c.1308024069.git.joe@perches.com>,<C4E199C967B4824F9C9DF4C42CE4A3B8591B7F0D78@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <acme@ghostprotocols.net>, <jcliburn@gmail.com>,
	<chris.snook@gmail.com>, <jie.yang@atheros.com>,
	<Sathya.Perla@Emulex.Com>, <subbu.seetharaman@emulex.com>,
	<rmody@brocade.com>, <ddutt@brocade.com>,
	<sjur.brandeland@stericsson.com>, <divy@chelsio.com>,
	<leitao@linux.vnet.ibm.com>, <amit.salecha@qlogic.com>,
	<ron.mercer@qlogic.com>, <linux-driver@qlogic.com>,
	<anirban.chakraborty@qlogic.com>, <jdmason@kudzu.us>,
	<linux-net-drivers@solarflare.com>, <shodgson@solarflare.com>,
	<bhutchings@solarflare.com>, <venza@brownhat.org>,
	<dave@thedillows.org>, <linux-kernel@vger.kernel.org>
To: <joe@perches.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:35967 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751553Ab1FNScj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 14:32:39 -0400
In-Reply-To: <C4E199C967B4824F9C9DF4C42CE4A3B8591B7F0D78@EXMAIL.ad.emulex.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Subject: [PATCH net-next 2/2] drivers/net: Remove casts of void *
>
> Unnecessary casts of void * clutter the code.
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
> index 0c12c2d..30719f5 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -2334,8 +2334,7 @@ int be_cmd_get_cntl_attributes(struct be_adapter
> *adapter)
>
>       status = be_mbox_notify_wait(adapter);
>       if (!status) {
> -             attribs = (struct mgmt_controller_attrib *)( attribs_cmd.va
> +
> -                                     sizeof(struct be_cmd_resp_hdr));
> +             attribs = attribs_cmd.va + sizeof(struct be_cmd_resp_hdr);
>               adapter->hba_port_num = attribs->hba_attribs.phy_port;
>       }
>
> diff --git a/drivers/net/benet/be_ethtool.c
> b/drivers/net/benet/be_ethtool.c
> index facfe3c..5572c78 100644
> --- a/drivers/net/benet/be_ethtool.c
> +++ b/drivers/net/benet/be_ethtool.c
> @@ -386,7 +386,7 @@ static int be_get_settings(struct net_device
> *netdev, struct ethtool_cmd *ecmd)
>               }
>               status = be_cmd_get_phy_info(adapter, &phy_cmd);
>               if (!status) {
> -                     resp = (struct be_cmd_resp_get_phy_info *)
> phy_cmd.va;
> +                     resp = phy_cmd.va;
>                       intf_type = le16_to_cpu(resp->interface_type);
>
>                       switch (intf_type) {
> @@ -690,7 +690,7 @@ be_read_eeprom(struct net_device *netdev, struct
> ethtool_eeprom *eeprom,
>       status = be_cmd_get_seeprom_data(adapter, &eeprom_cmd);
>
>       if (!status) {
> -             resp = (struct be_cmd_resp_seeprom_read *) eeprom_cmd.va;
> +             resp = eeprom_cmd.va;
>               memcpy(data, resp->seeprom_data + eeprom->offset, eeprom-
> >len);
>       }
>       dma_free_coherent(&adapter->pdev->dev, eeprom_cmd.size,
> eeprom_cmd.va,

The be2net part of the patch looks good.

Acked-by: Ajit Khaparde ajit.khaparde@emulex.com