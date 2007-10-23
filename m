From: Patrick McHardy <kaber@trash.net>
Subject: Re: sch_prio.c vs CONFIG_NETDEVICES_MULTIQUEUE
Date: Tue, 23 Oct 2007 14:17:36 +0200
Message-ID: <471DE660.4090004@trash.net>
References: <20071023121420.GB6267@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	Pavel Emelyanov <xemul@openvz.org>
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43923 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbXJWMSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 08:18:34 -0400
In-Reply-To: <20071023121420.GB6267@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CCed Pavel

Alexey Dobriyan wrote:
> gcc spits following warnings
> 
> net/sched/sch_prio.c:139: warning: passing argument 2 of 'netif_subqueue_stopped' makes pointer from integer without a cast
> net/sched/sch_prio.c:169: warning: passing argument 2 of 'netif_subqueue_stopped' makes pointer from integer without a cast
> 
> and he is dead right -- passing integer instead of skb is not going to
> work:
> 
> 	if (!netif_subqueue_stopped(sch->dev, (q->mq ? prio : 0))) {
> 
> skb_get_queue_mapping will ignore it if multiqueue support is off and
> dereference it otherwise.
