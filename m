From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: sky2 panic in 2.6.32.1 under load (new oops)
Date: Tue, 29 Dec 2009 20:15:50 +0100
Message-ID: <4B3A5566.7060400@gmail.com>
References: <4B300A2A.8040305@gmail.com> <4B300E30.9090707@majjas.com> <4B3114E3.1070602@majjas.com> <4B329FA3.9090904@majjas.com> <20091223230102.4bb0100e.akpm@linux-foundation.org> <4B34E847.8010809@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Berck E. Nash" <flyboy@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752517AbZL2TQH@vger.kernel.org>
In-Reply-To: <4B34E847.8010809@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Breuer wrote, On 12/25/2009 05:28 PM:

>   More data points - I'm able to reliably recreate this now.
> While I thought it was coincidence, each and every time I hit this issue 
> there is a DHCP renew event immediately before the first error.


Maybe it's totally unconnected and some different NetworkManager, but FYI,
there was reported a strange interaction of KNetworkManager vs 2.6.32:
http://bugzilla.kernel.org/show_bug.cgi?id=14794

Jarek P.

> The crash occurs while under load - in my case seems that the traffic is 
> actually IPV6 (hadn't noticed that before).
> I ran nethogs on a remote display - the reported rx rate on the IPV6 smb 
> connection at the time of the lockup was 33889.688 KB/sec on a 1gbit 
> nic. I've got two events like this - don't recall if the earlier one was 
> the exact same # - but it was in the ballpark.
> 
...
>>> Dec 23 17:33:29 mail NetworkManager:<info>   (eth0): carrier now ON
>>> (device state 1)
>>> Dec 23 17:33:30 mail named[4284]: client 114.80.99.2#44695: view
>>> External: query (cache) './NS/IN' denied
>>> Dec 23 17:33:38 mail named[4284]: error (connection refused) resolving
>>> '121.93.27.216.blackholes.mail-abuse.org/A/IN': 168.61.5.195#53
>>> Dec 23 17:33:44 mail kernel: sky2 eth0: tx timeout
>>> Dec 23 17:33:44 mail kernel: sky2 eth0: disabling interface
>>> Dec 23 17:33:44 mail kernel: sky2 eth0: enabling interface
>>> Dec 23 17:33:44 mail NetworkManager:<info>   (eth0): carrier now OFF
>>> (device state 1)
>>> Dec 23 17:33:49 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
>>> duplex, flow control both
>>> Dec 23 17:33:49 mail NetworkManager:<info>   (eth0): carrier now ON
>>> (device state 1)
>>> Dec 23 17:33:52 mail dhcpd: DHCPINFORM from 10.0.0.11 via eth0
>>> Dec 23 17:33:52 mail dhcpd: DHCPACK to 10.0.0.11 (00:1a:92:8d:30:81) via
>>> eth0
>>> Dec 23 17:34:01 mail smbd[24783]: [2009/12/23 17:34:01,  0]
>>> lib/util_sock.c:539(read_fd_with_timeout)
>>> Dec 23 17:34:01 mail smbd[24783]: [2009/12/23 17:34:01,  0]
>>> lib/util_sock.c:1491(get_peer_addr_internal)
>>> Dec 23 17:34:01 mail smbd[24783]:   getpeername failed. Error was
>>> Transport endpoint is not connected
>>> Dec 23 17:34:01 mail smbd[24783]:   read_fd_with_timeout: client 0.0.0.0
>>> read error = Connection reset by peer.
>>> Dec 23 17:34:04 mail abrt: Kerneloops: Reported 1 kernel oopses to Abrt
>>> Dec 23 17:34:04 mail abrtd: Directory 'kerneloops-1261607644-1' creation
>>> detected
>>> Dec 23 17:34:04 mail abrtd: Getting local universal unique identification
>>> Dec 23 17:34:04 mail abrtd: New crash, saving
>>> Dec 23 17:34:04 mail abrtd: Activation of plugin 'RunApp' was not
>>> successful: Plugin 'RunApp' is not registered
>>> Dec 23 17:34:04 mail kernel: sky2 eth0: tx timeout
>>> Dec 23 17:34:04 mail kernel: sky2 eth0: disabling interface
>>> Dec 23 17:34:04 mail kernel: sky2 eth0: enabling interface
>>> Dec 23 17:34:04 mail NetworkManager:<info>   (eth0): carrier now OFF
>>> (device state 1)
>>> Dec 23 17:34:09 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
>>> duplex, flow control both
>>> Dec 23 17:34:09 mail NetworkManager:<info>   (eth0): carrier now ON
>>> (device state 1)
>>> Dec 23 17:34:11 mail logger: ping of potter failed
>>> Dec 23 17:34:19 mail kernel: sky2 eth0: tx timeout
>>> Dec 23 17:34:19 mail kernel: sky2 eth0: disabling interface
>>> Dec 23 17:34:19 mail kernel: sky2 eth0: enabling interface
>>> Dec 23 17:34:19 mail NetworkManager:<info>   (eth0): carrier now OFF
>>> (device state 1)
>>> Dec 23 17:34:22 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full
>>> duplex, flow control both
>>> Dec 23 17:34:22 mail NetworkManager:<info>   (eth0): carrier now ON
>>> (device state 1)
