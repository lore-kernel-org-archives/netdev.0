From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net] WARNING: CPU: 1 PID: 1 at net/batman-adv/hard-interface.c:92
 batadv_is_on_batman_iface()
Date: Wed, 21 May 2014 23:12:36 -0700
Message-ID: <CAHA+R7Mhd2KYaU8THAd+O4HzQNRLxhpGccvEPOqWJRKAwZbpgQ@mail.gmail.com>
References: <537D8030.8010403@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Jet Chen <jet.chen@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:37488 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbaEVGMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 02:12:37 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so5019465qgd.1
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 23:12:37 -0700 (PDT)
In-Reply-To: <537D8030.8010403@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 21, 2014 at 9:42 PM, Jet Chen <jet.chen@intel.com> wrote:
> Hi Steffen,
>
> 0day kernel testing robot got the below dmesg and the first bad commit is
>
> git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
> commit 78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb
> Author:     Steffen Klassert <steffen.klassert@secunet.com>
> AuthorDate: Mon May 19 11:36:56 2014 +0200
> Commit:     David S. Miller <davem@davemloft.net>
> CommitDate: Wed May 21 02:08:32 2014 -0400
>
>     ip_tunnel: Initialize the fallback device properly
>         We need to initialize the fallback device to have a correct mtu
>     set on this device. Otherwise the mtu is set to null and the device
>     is unusable.
>         Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
>     Cc: Pravin B Shelar <pshelar@nicira.com>
>     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> +--------------------------------------------------------------------------------+------------+------------+
> |
> | d8d33c3b8a | 78ff4be45a |
> +--------------------------------------------------------------------------------+------------+------------+
> | boot_successes
> | 60         | 0          |
> | boot_failures
> | 0          | 20         |
> |
> WARNING:CPU:PID:at_net/batman-adv/hard-interface.c:batadv_is_on_batman_iface()
> | 0          | 20         |
> | backtrace:register_netdevice_notifier
> | 0          | 20         |
> | backtrace:batadv_init
> | 0          | 20         |
> | backtrace:kernel_init_freeable
> | 0          | 20         |
> +--------------------------------------------------------------------------------+------------+------------+
>

batman needs to fix:

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index b851cc5..fbda6b5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -83,7 +83,7 @@ static bool batadv_is_on_batman_iface(const struct
net_device *net_dev)
                return true;

        /* no more parents..stop recursion */
-       if (net_dev->iflink == net_dev->ifindex)
+       if (net_dev->iflink == 0 || net_dev->iflink == net_dev->ifindex)
                return false;

        /* recurse over the parent device */
