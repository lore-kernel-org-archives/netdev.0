From: Ben Greear <greearb@candelatech.com>
Subject: Re: [MacVLAN] failure to deliver reassembled IPv6 multicast traffic
Date: Fri, 15 Feb 2013 11:07:12 -0800
Message-ID: <511E8760.9070703@candelatech.com>
References: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, ataschner@suse.com
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38959 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755Ab3BOTH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 14:07:26 -0500
In-Reply-To: <20130215170028.GG12219@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2013 09:00 AM, Erik Hugne wrote:
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

This has been around for a long time, maybe forever.  Last time
we looked at this it did not appear there was an easy fix, something
to do with how UDP packets are re-assembled....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
