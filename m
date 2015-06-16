From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: Include -E option for socket destroy events
Date: Tue, 16 Jun 2015 09:50:55 -0700
Message-ID: <1434473455.27504.179.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1434470578-25796-1-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	edumazet@google.com
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:33298 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754639AbbFPQu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 12:50:57 -0400
Received: by igbos3 with SMTP id os3so48450355igb.0
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 09:50:56 -0700 (PDT)
In-Reply-To: <1434470578-25796-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-16 at 12:02 -0400, Craig Gallek wrote:
> Use the IPv4/IPv6/TCP/UDP multicast groups of NETLINK_SOCK_DIAG
> to filter and display socket statistics as they are destroyed.
> 
> Kernel support patch series: 24029a3603cfa633e8bc2b3fb3e48e76c497831d
> 
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---
>  include/linux/inet_diag.h |  3 +-
>  include/linux/sock_diag.h | 10 +++++++
>  misc/ss.c                 | 72 ++++++++++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 83 insertions(+), 2 deletions(-)

I am not sure filter works, and apparently some fields are not properly
reported ? (source port for example looks wrong)

(Note : you probably need to filter in user space, but ss should already
have support for this)

lpaa23:~# ./ss -Eit dst 10.246.7.152
State       Recv-Q Send-Q Local Address:Port                 Peer Address:Port                
UNCONN      0      1         ::ffff:10.246.7.151:*                      ::ffff:10.126.178.16:14354                
	 wscale:7,7 rto:221 rtt:20.165/5.91 ato:40 mss:1448 cwnd:10 send 5.7Mbps lastsnd:21 lastrcv:15023 lastack:1 pacing_rate 11.5Mbps unacked:1 rcv_rtt:20 rcv_space:28960
UNCONN      0      1       127.0.0.1:*                     127.0.0.1:9551                 
	 rto:1000 mss:524 cwnd:10 lastsnd:67817 lastrcv:67817 lastack:67817 unacked:1
UNCONN      0      1       127.0.0.1:*                     127.0.0.1:9551                 
	 rto:1000 mss:524 cwnd:10 lastsnd:67818 lastrcv:67818 lastack:67818 unacked:1
UNCONN      0      1       127.0.0.1:*                     127.0.0.1:9551                 
	 rto:1000 mss:524 cwnd:10 lastsnd:68742 lastrcv:68742 lastack:68742 unacked:1
UNCONN      0      0      10.246.7.151:*                    10.246.7.152:50227                
	 wscale:7,7 rto:201 rtt:0.203/0.209 mss:1448 cwnd:254 ssthresh:251 send 14494.3Mbps lastsnd:1 lastrcv:71533 pacing_rate 28970.7Mbps retrans:0/5 rcv_space:29200
UNCONN      0      0      10.246.7.151:*                    10.246.7.152:12865                
	 wscale:7,7 rto:201 rtt:0.363/0.375 ato:40 mss:1448 cwnd:10 ssthresh:293 send 319.1Mbps lastsnd:1004 lastrcv:1 lastack:1 pacing_rate 636.7Mbps rcv_rtt:126.125 rcv_space:29200
UNCONN      0      1       127.0.0.1:*                     127.0.0.1:9551                 
	 rto:1000 mss:524 cwnd:10 lastsnd:73036 lastrcv:73036 lastack:73036 unacked:1
^C
