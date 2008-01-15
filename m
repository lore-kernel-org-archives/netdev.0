From: Patrick McHardy <kaber@trash.net>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Tue, 15 Jan 2008 17:05:42 +0100
Message-ID: <478CD9D6.3000504@trash.net>
References: <478C94B7.3070503@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43487 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751363AbYAOQFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 11:05:54 -0500
In-Reply-To: <478C94B7.3070503@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Badalian Vyacheslav wrote:
> Hello all. Have packetlost when do "tc qdisc del dev eth0 root".
> 
> look:
> 
> slavon ~ # ping -f 87.255.1.134
> PING 87.255.1.134 (87.255.1.134) 56(84) bytes of data.
> .
> ..................................................................................................................................................................................................................................................................... 
> 
> .
> --- 87.255.1.134 ping statistics ---
> 60811 packets transmitted, 60544 received, 0% packet loss, time 39528ms
> rtt min/avg/max/mdev = 0.203/0.579/3227.655/13.124 ms, pipe 219, 
> ipg/ewma 0.650/2.197 ms
> 
> Its normal?

Yes, packets in the old qdisc are lost.

> Maybe if tc do changes - need create second queue (hash of rules or how 
> you named it?) and do changes at it. Then replace old queue rules by 
> created new.
> Logic -
> 1. Do snapshot
> 2. Do changes in shapshot
> 3. All new packets go to snapshot
> 4. If old queue not have packets - delete it.
> 5. Snapshot its default.


That doesn't really work since qdiscs keep internal state that
in large parts depends on the packets queued. Take the qlen as
a simple example, the new qdisc doesn't know about the packets
in the old one and will exceed the limit.
