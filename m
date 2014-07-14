From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] openvswitch: Allow each vport to have an array
 of 'port_id's.
Date: Mon, 14 Jul 2014 15:13:37 -0700 (PDT)
Message-ID: <20140714.151337.573086784322485064.davem@davemloft.net>
References: <1405296774-3648-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexw@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756122AbaGNWNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 18:13:38 -0400
In-Reply-To: <1405296774-3648-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Sun, 13 Jul 2014 17:12:54 -0700

>  void ovs_vport_free(struct vport *vport)
>  {
> +	kfree((struct vport_portids __force *)vport->upcall_portids);

This cast is ugly and never correct for this situation, you need to
use rcu_dereference().
