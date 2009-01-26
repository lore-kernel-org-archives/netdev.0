From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] gianfar: Revive VLAN support
Date: Mon, 26 Jan 2009 15:07:37 -0600
Message-ID: <324701F1-4A84-41A6-BC2D-4A61A8E135D9@freescale.com>
References: <20090126205043.GA15581@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Dai Haruki <dai.haruki@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35320 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbZAZVIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 16:08:00 -0500
In-Reply-To: <20090126205043.GA15581@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 26, 2009, at 2:50 PM, Anton Vorontsov wrote:

> commit 77ecaf2d5a8bfd548eed3f05c1c2e6573d5de4ba ("gianfar: Fix VLAN
> HW feature related frame/buffer size calculation") wrongly removed
> priv->vlgrp assignment, and now priv->vlgrp is always NULL.
>
> This patch fixes the issue, plus fixes following sparse warning
> introduced by the same commit:
> gianfar.c:1406:13: warning: context imbalance in  
> 'gfar_vlan_rx_register' - wrong count at exit
>
> gfar_vlan_rx_register() checks for "if (old_grp == grp)" and tries
> to return w/o dropping the lock.
>
> According to net/8021q/vlan.c VLAN core issues rx_register() callback:
> 1. In register_vlan_dev() only on a newly created group;
> 2. In unregister_vlan_dev() only if the group becomes empty.
>
> Thus the check in the gianfar driver isn't needed.
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Acked-by: Andy Fleming <afleming@freescale.com>
