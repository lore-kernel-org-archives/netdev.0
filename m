From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH v2 net-next 0/7] Non-promisc bidge ports support
Date: Wed, 30 Apr 2014 10:22:41 -0700
Message-ID: <20140430102241.2fa8ac7b@nehalam.linuxnetplumber.net>
References: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	shemminger@vyatta.com, jhs@mojatatu.com,
	john.r.fastabend@intel.com, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:52501 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758944AbaD3RWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 13:22:48 -0400
Received: by mail-ig0-f177.google.com with SMTP id h3so2148391igd.10
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 10:22:47 -0700 (PDT)
In-Reply-To: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Apr 2014 17:20:21 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> This patch series is a re-implementation of prior attempts to support
> non-promiscuous bridge ports.
> 
> The basic concept is the same as before.  The bridge keeps
> track of the ports that support learning and flooding packets
> to unknown destinations.  We call these ports auto-discovery
> ports since they automatically discover who is behind them through
> learning and flooding.  
> 
> If flooding and learning are disabled via flags, then the port
> requires static configuration to tell it which mac addresses
> are behind it.  This is accomplished through adding of fdbs.
> These fdbs should be static as dynamic fdbs can expire and systems
> will become unreachable due to lack of flooding.
> 
> If the user marks all ports are needing static configuration then
> we can safely make them non-promiscuous, we will know all the
> information about them.
> 
> If the user leaves only 1 port as automatic, then we can mark
> that port as not-promiscuous as well.  One could think of
> this a edge relay similar to what's support by embedded switches
> in SRIOV devices.  Since we have all the information about the
> other ports, we can just program the mac addresses into the
> single automatic port to receive all necessary traffic.
> 
> In other cases, we keep all ports promiscuous as before.
> 
> There are some other cases when promiscuous mode has to be turned
> back on.  One is when the bridge itself if placed in promiscuous
> mode (use sets promisc flag).  The other is if vlan filtering is
> turned off.  Since this is the default configuration, the default
> bridge operation is not changed.

I like this because it does the right thing and is transparent to
the user. You might also not want to do it if the underlying device
does not support multiple MAC addresses 
ie !(dev->priv_flags & IFF_UNICAST_FLT)


You could even go into looking at L2 offload on lower device.
