From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch] netxen_nic: Bugfix for wrong RUNNING status of NX3031
 NICs with no link
Date: Thu, 2 Jan 2014 14:47:13 +0000
Message-ID: <1388674033.1607.3.camel@bwh-desktop.uk.level5networks.com>
References: <OFAE440C7C.FE33E30C-ON48257C54.0013C383-48257C54.0013F43B@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	<netdev@vger.kernel.org>, <li.fengmao@zte.com.cn>
To: <jiang.biao2@zte.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17723 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaABOrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 09:47:31 -0500
In-Reply-To: <OFAE440C7C.FE33E30C-ON48257C54.0013C383-48257C54.0013F43B@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 11:37 +0800, jiang.biao2@zte.com.cn wrote:
> From: Li Fengmao <li.fengmao@zte.com.cn>
> 
> Ifconfig command displays RUNNING status when there is no link on
> NX3031 NICs. The problem is caused by the wrong calling order of
> netif_carrier_off() and register_netdev() in netxen_setup_netdev(),
> dev->reg_state is initialized to NETREG_UNINITIALIZED before
> registering network device, so the linkwatch_fire_event() will not
> be called to notify the link change event in netif_carrier_off(),
> and the operational status of network device will be set to
> IF_OPER_UNKNOWN. In that case, the IFF_RUNNING flags will be set,
> which result in the wrong RUNNING status in the result of ifconfig
> command.
[...]

This was fixed in Linux 3.7.  The driver should not be changed.

(This change may be worthwhile in an out-of-tree version for older
kernel versions, but beware of races with opening of the device.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
