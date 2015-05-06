From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] switchdev: add support for fdb add/del/dump
 via switchdev_port_obj ops.
Date: Wed, 06 May 2015 19:35:12 -0400
Message-ID: <554AA530.7000702@mojatatu.com>
References: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Sridhar Samudrala <sridhar.samudrala@intel.com>, sfeldma@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:33200 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbEFXfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 19:35:14 -0400
Received: by iepj10 with SMTP id j10so23867422iep.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 16:35:13 -0700 (PDT)
In-Reply-To: <1430949253-6358-1-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/15 17:54, Sridhar Samudrala wrote:
> - introduce port fdb obj and generic switchdev_port_fdb_add/del/dump()
> - use switchdev_port_fdb_add/del/dump in rocker/team/bonding ndo ops.
> - add support for fdb obj in switchdev_port_obj_add/del/dump()
> - switch rocker to implement fdb ops via switchdev_ops
>
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---



So i raised this earlier. DaveM also chimed in - but it seems still
in there.
i havent been following the discussion and i may have missed
the agreement to keep the new IDs. Could we not just have used netlink
  IDs (as opposed to a new SWITCHDEV_OBJ_PORT_FDB id)?

> +int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
> +			   struct net_device *dev, const unsigned char *addr,
> +			   u16 vid, u16 nlm_flags)
> +{
> +	struct switchdev_obj obj = {
> +		.id = SWITCHDEV_OBJ_PORT_FDB,
> +		.fdb = {
> +			.addr = addr,
> +			.vid = vid,
> +		},
> +	};
> +
> +	return switchdev_port_obj_add(dev, &obj);
> +}

cheers,
jamal
