From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: fix compilation when vxlan is a
 module
Date: Sun, 26 Jul 2015 20:57:42 -0700 (PDT)
Message-ID: <20150726.205742.539016799227504892.davem@davemloft.net>
References: <1437643747-22976-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, dev@openvswitch.org,
	tgraf@suug.ch
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37829 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141AbbG0D5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 23:57:43 -0400
In-Reply-To: <1437643747-22976-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 23 Jul 2015 11:29:07 +0200

> With CONFIG_VXLAN=m and CONFIG_OPENVSWITCH=y, there was the following
> compilation error:
>   LD      init/built-in.o
>   net/built-in.o: In function `vxlan_tnl_create':
>   .../net/openvswitch/vport-netdev.c:322: undefined reference to `vxlan_dev_create'
>   make: *** [vmlinux] Error 1
> 
> CC: Thomas Graf <tgraf@suug.ch>
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied as a stop-gap measure to fix this, but this is a terrible
dependency.

There is no reason a user should have to know that without vxlan
they aren't able to turn on openvswitch.
