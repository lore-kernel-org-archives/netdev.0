From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Tue, 19 Mar 2013 14:21:41 -0700
Message-ID: <20130319142141.5d32cae2@nehalam.linuxnetplumber.net>
References: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:64939 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab3CSVVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 17:21:47 -0400
Received: by mail-pd0-f180.google.com with SMTP id g10so325165pdj.39
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 14:21:47 -0700 (PDT)
In-Reply-To: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Mar 2013 11:13:25 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> Following patch refactors GRE code into ip tunneling code and GRE
> specific code. Common tunneling code is moved to ip_tunnel module.
> ip_tunnel module is written as generic library which can be used
> by different tunneling implementations.
> 
> ip_tunnel module contains following components:
>  - packet xmit and rcv generic code. xmit flow looks like
>    (gre_xmit/ipip_xmit)->ip_tunnel_xmit->ip_local_out.
>  - hash table of all devices.
>  - lookup for tunnel devices.
>  - control plane operations like device create, destroy, ioctl, netlink
>    operations code.
>  - registration for tunneling modules, like gre, ipip etc.
>  - define single pcpu_tstats dev->tstats.
>  - struct tnl_ptk_info added to pass parsed tunnel packet parameters.
> 
> ipip.h header is renamed to ip_tunnel.h
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Doesn't build with this patch alone (ie. not bisectable).


  CC [M]  net/ipv6/ip6_gre.o
net/ipv6/ip6_gre.c:41:27: fatal error: net/ip_tunnel.h: No such file or directory
compilation terminated.
