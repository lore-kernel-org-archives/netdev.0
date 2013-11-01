From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Fri, 1 Nov 2013 22:28:17 +0100
Message-ID: <20131101212817.GC30284@order.stressinduktion.org>
References: <20131028.204306.2213130677400093266.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com> <20131029124010.GA15762@order.stressinduktion.org> <20131029.155809.311976718174740421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David.Laight@ACULAB.COM, jiri@resnulli.us, vyasevich@gmail.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, thaller@redhat.com,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44082 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab3KAV2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 17:28:19 -0400
Content-Disposition: inline
In-Reply-To: <20131029.155809.311976718174740421.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 03:58:09PM -0400, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Tue, 29 Oct 2013 13:40:10 +0100
> 
> > It seems not that invasive to switch from af_packet to an udp socket
> > with SO_BROADCAST set.
> 
> Precisely!

dhclient compiled with --enable-use-sockets worked out of the box, I merely
had to fix a small compile error (most non-intrusive version):
https://github.com/hannes/isc-dhcp/commit/55c3b7d80541b38389244f67f7f5bdb16ad02474

# lsof -p $(pidof dhclient)
COMMAND   PID USER   FD   TYPE             DEVICE SIZE/OFF   NODE NAME
dhclient 1247 root  cwd    DIR              252,2     4096      2 /
dhclient 1247 root  rtd    DIR              252,2     4096      2 /
dhclient 1247 root  txt    REG              252,2  6683635 145354 /home/hannes/isc-dhcp/client/dhclient
dhclient 1247 root  mem    REG              252,2   162472  30914 /usr/lib64/ld-2.17.so
dhclient 1247 root  mem    REG              252,2  2108632  30915 /usr/lib64/libc-2.17.so
dhclient 1247 root  mem    REG              252,2    62368   2205 /usr/lib64/libnss_files-2.17.so
dhclient 1247 root    0u   CHR                1,3      0t0   1028 /dev/null
dhclient 1247 root    1u   CHR                1,3      0t0   1028 /dev/null
dhclient 1247 root    2u   CHR                1,3      0t0   1028 /dev/null
dhclient 1247 root    3u  unix 0xffff880114b3c200      0t0  20634 socket
dhclient 1247 root    4w   REG              252,2      802 539097 /var/db/dhclient.leases
dhclient 1247 root    5u  IPv4              20658      0t0    UDP *:bootpc 
dhclient 1247 root   20u  IPv4              20635      0t0    UDP *:43148 
dhclient 1247 root   21u  IPv6              20636      0t0    UDP *:37190 


Broadcasts get dropped when rp_filter is activated and no ip address
is bound for that interface. Do we want to relax the restriction for
broadcast so dhcp with sockets can be shipped by default?

Greetings,

  Hannes
