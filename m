From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: TCP connection stops after high load.
Date: Thu, 12 Apr 2007 23:11:14 +0200
Message-ID: <7e63f56c0704121411w6faea114g756d780b5a011463@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Ben Greear" <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:57237 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbXDLVLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 17:11:16 -0400
Received: by ug-out-1314.google.com with SMTP id 44so419345uga
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2007 14:11:15 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

On 4/11/07, Ben Greear <greearb@candelatech.com> wrote:
>  The problem is that I set up a TCP connection with bi-directional traffic
> of around 800Mbps, doing large (20k - 64k writes and reads) between two ports on
> the same machine (this 2.6.18.2  kernel is tainted with my full patch set,
> but I also reproduced with only the non-tainted send-to-self patch applied
> last may on the 2.6.16 kernel, so I assume the bug is not particular to my patch
> set).
>
>  At first, all is well, but within 5-10 minutes, the TCP connection will stall
> and I only see a massive amount of duplicate ACKs on the link.
>

Just today I have faced some problems in the setup lighttpd server
(epoll demultiplexing and increased max-fds num) against curl-loader,
generating HTTP client load, both on the same host.

curl-loader adds 1000-8000 secondary IPv4 addresses to
eth0 interface. Then it opens 20-200 virtual HTTP clients per second till the
steady state number. Each client opens its socket, binds to a
secondary IP-address
and connects to the web server with further HTTP GET/POST, etc
response, etc

It works good with  2.6.11.8 and debian 2.6.18.3-i686 image.

At the same Intel Pentium-4 PC with the same about kernel configuration
(make oldconfig using Debian config-2.6.18.3-i686) the setup fails with the
tcp-connections stalled after 1000 established connections when the kernel
is 2.6.20.6 or 2.6.19.5.

It stalls even earlier, when lighttpd used with the default (poll ())
demultiplexing
after 500 connections or when apache2 web server used (memory?) - after 100
connections.

I am currently going to try vanilla 2.6.18.3 and, if with it also
fails, to look through
Debian patches, trying to figure out, what is the delta.

strace-ing and logs has revealed actually 2 scenarios of failures.
Connections are established successfully and:
- request sent and there is no response;
- partial response received and the connection stalls.

I will also try to collect some streams by tcpdump, using
the filtering by a client side source-ip.

Already tried going from BIC to Reno - not helpful, and loading
from the loopback (lo) - same picture.

Don't fill yourself alone, it may be the same problem, that
we encounter.

Sincerely,
 Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...................................................................
Navigare necesse est, vivere non est necesse
...................................................................
http://curl-loader.sourceforge.net
An open-source HTTP/S, FTP/S traffic
generating, and web testing tool.
