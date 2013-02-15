From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Fri, 15 Feb 2013 10:08:10 -0800
Message-ID: <1360951690.19353.20.camel@edumazet-glaptop>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, ataschner@suse.com
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:59861 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756805Ab3BOSIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 13:08:13 -0500
Received: by mail-pa0-f41.google.com with SMTP id fb11so1874042pad.28
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 10:08:12 -0800 (PST)
In-Reply-To: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 18:00 +0100, Erik Hugne wrote:
> If macvlan's are configured on a device, IPv6 multicast
> traffic received on the underlying ethernet device is not
> delivered properly to higher layers. Large amounts of packets are lost, and
> the problem seems to get worse the more macvlans are defined
> on top of the device, up to the point where no traffic is delivered
> at all...
> 
> 
> Steps to reproduce (2 hosts required)
> On host 1, set up some macvlans:
> ip link add link eth0 name macvlan0 type macvlan mode bridge
> ip link add link eth0 name macvlan2 type macvlan mode bridge
> ip link add link eth0 name macvlan3 type macvlan mode bridge
> ip link set link dev macvlan0 up
> ip link set link dev macvlan2 up
> ip link set link dev macvlan3 up
> 
> Start a server that binds to ff02::1 scoped to eth0
> ./server6 -sff02::1 -eeth0
> 
> 
> On host 2:
> ./client6 -dff02::1 -eeth0
> 
> 
> This seems to only occur for large (fragmented) IPv6 multicast traffic.
> If you bind to :: instead (-s:: on the server) and send to
> the linklocal address of Host1/eth0, packets are delivered just fine.
> 
> Source for client6/server6 on github:
> git clone git@github.com:Hugne/udp_mc.git

I guess we need to defrag before doing the broadcast,
as we did for IPv4 in commit bc416d9768aa9a2e4
(macvlan: handle fragmented multicast frames)
