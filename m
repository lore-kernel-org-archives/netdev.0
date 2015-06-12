From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 05/19] bna: use BIT(x) instead of (1 << x)
Date: Fri, 12 Jun 2015 13:30:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB4D859@AcuExch.aculab.com>
References: <1434030751-28835-1-git-send-email-ivecera@redhat.com>
 <1434030751-28835-6-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "rasesh.mody@qlogic.com" <rasesh.mody@qlogic.com>,
	"joe@perches.com" <joe@perches.com>
To: 'Ivan Vecera' <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:53983 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754150AbbFLNcb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 09:32:31 -0400
In-Reply-To: <1434030751-28835-6-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera
...
> diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
> b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
> index 679a503..16090fd 100644
> --- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
> +++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
> @@ -75,7 +75,7 @@ enum {
>  	CB_GPIO_FC4P2   = (4),		/*!< 4G 2port FC card		*/
>  	CB_GPIO_FC4P1   = (5),		/*!< 4G 1port FC card		*/
>  	CB_GPIO_DFLY    = (6),		/*!< 8G 2port FC mezzanine card	*/
> -	CB_GPIO_PROTO   = (1 << 7)	/*!< 8G 2port FC prototypes	*/
> +	CB_GPIO_PROTO   = BIT(7)	/*!< 8G 2port FC prototypes	*/

That doesn't look like a BIT() value to me, just a large number.
Should the release driver even have support for the prototype hardware?

...
> -		if (rx_enet_mask & ((u32)(1 << i))) {
> +		if (rx_enet_mask & ((u32)BIT(i))) {

The (u32) cast looks superfluous.
There are also too many ().

...
> -	int bit = (1 << (vlan_id & BFI_VLAN_WORD_MASK));
> +	int bit = BIT((vlan_id & BFI_VLAN_WORD_MASK));

Too many ()

	David
