From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: add a sysctl to reflect the fwmark on replies
Date: Thu, 3 Apr 2014 14:10:53 +0200
Message-ID: <20140403121053.GB13354@order.stressinduktion.org>
References: <CAKD1Yr1nGPY131oDrHHHNyhatE3nHFA+Tb4QfVv-mTTHY7B=Yw@mail.gmail.com> <1396515601-24880-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net, ja@ssi.bg
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48695 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbaDCMKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 08:10:54 -0400
Content-Disposition: inline
In-Reply-To: <1396515601-24880-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 03, 2014 at 06:00:01PM +0900, Lorenzo Colitti wrote:
> Kernel-originated IP packets that have no user socket associated
> with them (e.g., ICMP errors and echo replies, TCP RSTs, etc.)
> are emitted with a mark of zero. Add a sysctl to make them have
> the same mark as the packet they are replying to.
> 
> This allows an administrator that wishes to do so to use
> mark-based routing, firewalling, etc. for these replies by
> marking the original packets inbound.
> 
> Tested using user-mode linux:
>  - ICMP/ICMPv6 echo replies and errors.
>  - TCP RST packets (IPv4 and IPv6).

Hmm, maybe add two sysctls to distinguish between IPv4 and IPv6?

We share the sysctl namespace for tcp with ipv4, but otherwise the knobs
are isolated if they touch ip-only behaviour.

Also net-next is currently closed, so the patch would have to wait until it
opens back up in a few weeks(?).

Bye,

  Hannes
