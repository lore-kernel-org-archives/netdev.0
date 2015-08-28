From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 4/4] vxlan: do not receive IPv4 packets on
 IPv6 socket
Date: Sat, 29 Aug 2015 00:39:29 +0200
Message-ID: <20150828223929.GC32001@pox.localdomain>
References: <cover.1440787600.git.jbenc@redhat.com>
 <823880925bf39790189708fcb7f7158f21231237.1440787601.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36118 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbbH1Wjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 18:39:31 -0400
Received: by wicfv10 with SMTP id fv10so18473672wic.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 15:39:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <823880925bf39790189708fcb7f7158f21231237.1440787601.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/15 at 08:48pm, Jiri Benc wrote:
> By default (subject to the sysctl settings), IPv6 sockets listen also for
> IPv4 traffic. Vxlan is not prepared for that and expects IPv6 header in
> packets received through an IPv6 socket.
> 
> In addition, it's currently not possible to have both IPv4 and IPv6 vxlan
> tunnel on the same port (unless bindv6only sysctl is enabled), as it's not
> possible to create and bind both IPv4 and IPv6 vxlan interfaces and there's
> no way to specify both IPv4 and IPv6 remote/group IP addresses.
> 
> Set IPV6_V6ONLY on vxlan sockets to fix both of these issues. This is not
> done globally in udp_tunnel, as l2tp and tipc seems to work okay when
> receiving IPv4 packets on IPv6 socket and people may rely on this behavior.
> The other tunnels (geneve and fou) do not support IPv6.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Can we fix VXLAN instead? It should be possible to receive and send both
v4 and v6 frames and represent it with metadata on a single socket.

Maybe set the flag if IFLA_VXLAN_COLLECT_METADATA is not set?
