From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/4] net: Find the nesting level of a given device by
 type.
Date: Fri, 16 May 2014 10:32:48 -0700
Message-ID: <1400261568.7973.225.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400260697-32601-1-git-send-email-vyasevic@redhat.com>
	 <1400260697-32601-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong@huawei.com, kaber@trash.net,
	vfalico@gmail.com, jiri@resnulli.us
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:61925 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757638AbaEPRcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 13:32:51 -0400
Received: by mail-pa0-f53.google.com with SMTP id kp14so2827431pab.12
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 10:32:50 -0700 (PDT)
In-Reply-To: <1400260697-32601-2-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 13:18 -0400, Vlad Yasevich wrote:
> Multiple devices in the kernel can be stacked/nested and they
> need to know their nesting level for the purposes of lockdep.
> This patch provides a generic function that determines a nesting
> level of a particular device by its type (ex: vlan, macvlan, etc).
> We only care about nesting of the same type of devices.
> 
> For example:
>   eth0 <- vlan0.10 <- macvlan0 <- vlan1.20
> 
> The nesting level of vlan1.20 would be 1, since there is another vlan
> in the stack under it.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>  include/linux/netdevice.h | 10 ++++++++++
>  net/core/dev.c            | 48 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 58 insertions(+)

Nice, but if LOCKDEP is not used, do we really want to have
dev_get_nest_level() being something else than a constant ?
