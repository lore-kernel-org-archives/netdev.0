From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 0/3] net: propagate dynamic needed_headroom/tailroom
 changes
Date: Tue, 20 Aug 2013 15:29:50 +0200
Message-ID: <20130820132950.GA1593@minipsycho.brq.redhat.com>
References: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amwang@redhat.com,
	stephen@networkplumber.org, kaber@trash.net, davem@davemloft.net,
	vyasevic@redhat.com, johannes@sipsolutions.net,
	eric.dumazet@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:51445 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab3HTN3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 09:29:55 -0400
Received: by mail-wg0-f53.google.com with SMTP id c11so370571wgh.8
        for <netdev@vger.kernel.org>; Tue, 20 Aug 2013 06:29:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1377002752-4622-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 20, 2013 at 02:45:49PM CEST, f.fainelli@gmail.com wrote:
>Hi all,
>
>This patchset aims at allowing dynamically changing a given device
>needed_headroom/tailroom space and propagating such events to stacked
>devices such as bridges and vlans.

You should also add support for other stacked devices, like bonding,
team, macvlan, ovs-datapath, etc.	
	
>
>Unless callers use the new helpers (dev_set_headroom/dev_set_tailroom)
>there is no functional change introduced.
>
>I tested this with an out of tree Ethernet driver with both VLANs and
>bridges and the need for a 64-byte headroom to insert a transmit
>status descriptor in front of a SKB.

Would be nice to add at least one driver which would use your new api.

Thanks,
	Jiri

>
>Since I am not familiar with all subsystems/drivers changing the
>needed_headroom/tailroom requirements, I would leave that to them.
>
>Florian Fainelli (3):
>  net: add a new NETDEV_CHANGEROOM event type
>  net: vlan: handle NETDEV_CHANGEROOM events
>  net: bridge: handle NETDEV_CHANGEROOM event
>
> include/linux/netdevice.h |  3 +++
> net/8021q/vlan.c          |  7 +++++++
> net/bridge/br_if.c        | 32 ++++++++++++++++++++++++++++++++
> net/bridge/br_notify.c    |  5 +++++
> net/bridge/br_private.h   |  2 ++
> net/core/dev.c            | 46 ++++++++++++++++++++++++++++++++++++++++++++++
> 6 files changed, 95 insertions(+)
>
>-- 
>1.8.1.2
>
>
