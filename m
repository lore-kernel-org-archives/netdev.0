From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, allow segmentation for gre tunneled skbs
Date: Fri, 12 Aug 2016 08:18:00 +0300
Message-ID: <20160812081800.02a98e17@halley>
References: <1470726261-16371-1-git-send-email-wenxu@ucloud.cn>
	<20160810.173511.968926810628735179.davem@davemloft.net>
	<20160811224132.7a17f0c3@halley>
	<80d116d7-e61c-1bbd-64bf-e3b1f809419b@ucloud.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, wenx05124561@163.com,
	hannes@stressinduktion.org
To: wenxu <wenxu@ucloud.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:34278 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbcHLFSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 01:18:10 -0400
Received: by mail-wm0-f47.google.com with SMTP id q128so1308503wma.1
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 22:18:09 -0700 (PDT)
In-Reply-To: <80d116d7-e61c-1bbd-64bf-e3b1f809419b@ucloud.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 12 Aug 2016 11:51:07 +0800 wenxu <wenxu@ucloud.cn> wrote:
> 
> And in b8247f095edd, the condition skb_iif also should be removed.
> given:
>      ovs-internal-dev bridge with ovs-gre
> 
> There are the same problem which the skb from local.

There's no need to remove the skb_iif criteria:

For the local bridge port, we have control over its mtu. This allows
setting an mtu value that takes into account the gre encapsulation
performed by other member ports.
By doing so, locally generated traffic (on br0) will have a proper
gso_size.

OTOH if packet arrives from an ingress member port (such as tap0) the
packet's gso_size could have been set by another system - which is not
always under our control.

( see discussion in http://www.spinics.net/lists/netdev/msg385085.html )

Regards,
Shmulik
