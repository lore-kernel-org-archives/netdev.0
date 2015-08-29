From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v2 net-next 4/4] vxlan: do not receive IPv4 packets on
 IPv6 socket
Date: Sat, 29 Aug 2015 10:55:44 +0200
Message-ID: <20150829105544.33b7799f@griffin>
References: <cover.1440787600.git.jbenc@redhat.com>
	<823880925bf39790189708fcb7f7158f21231237.1440787601.git.jbenc@redhat.com>
	<20150828223929.GC32001@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788AbbH2Izs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2015 04:55:48 -0400
In-Reply-To: <20150828223929.GC32001@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 29 Aug 2015 00:39:29 +0200, Thomas Graf wrote:
> Can we fix VXLAN instead? It should be possible to receive and send both
> v4 and v6 frames and represent it with metadata on a single socket.

That's actually what I intend to do next. But I need the flag and this
patch for that. If IPv6 is enabled, I'll open two sockets within a
single vxlan_sock for metadata based vxlan, IPv4 one and IPv6 one. It
would be easier to just open an IPv6 socket and receive both IPv4 and
IPv6 traffic through it but unfortunately, this depends on bindv6only
sysctl. We don't want to have IPv4 vxlan broken if bindv6only is set.
Therefore, we need two sockets, and the IPv6 one needs to be v6only.

 Jiri

-- 
Jiri Benc
