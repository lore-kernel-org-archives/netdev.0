From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection hang problem with 2.6.16.16, e1000.
Date: Wed, 31 May 2006 12:37:41 -0700
Message-ID: <447DF085.2050604@candelatech.com>
References: <447DC830.4080201@candelatech.com> <447DD870.80107@intel.com> <447DD9B5.9050100@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:5862 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751787AbWEaThl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 15:37:41 -0400
Received: from [71.112.216.116] (pool-71-112-216-116.sttlwa.dsl-w.verizon.net [71.112.216.116])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id k4VJbedW003102
	for <netdev@vger.kernel.org>; Wed, 31 May 2006 12:37:40 -0700
To: NetDev <netdev@vger.kernel.org>
In-Reply-To: <447DD9B5.9050100@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:

> I haven't seen this problem on 2.6.13, so I'm now starting a manual bisect
> to see if I can narrow down where the problem appeared.

Turns out, I can reproduce it in 2.6.13, and 2.6.9.  I haven't tried anything
older.

I also tried to reproduce it using a simpler traffic generation tool, but could
not reproduce the problem with it.  That points to something wierd that my application
is doing, but I can't imagine what user-space could do to screw up a TCP connection
like this.

In all cases, there is a lot of data in the send-queue, but for whatever
reason, the connection will not make progress.  To user-space, it appears
that poll returns neither readable nor writable for the sockets.

I notice that if I increase the send-buffer-size while the connection is
in the hung state, my app will quickly fill the larger send buffer, but
still receives nothing new.

Starting a new connection on the same interfaces works for a few seconds
and then hangs as well, so the NICs can pass traffic.

Here is output from /proc/net/tcp and netstat from the 2.6.16.16 kernel.

netstat info:

tcp        0 5635368 172.1.5.169:33058       172.1.5.168:33057       ESTABLISHED
tcp        0 5987504 172.1.5.168:33057       172.1.5.169:33058       ESTABLISHED

/proc/net/tcp:

   20: A90501AC:8122 A80501AC:8121 01 0055FD28:00000000 01:00001A9F 0000000A
0        0 21309 2 f36d8580 120000 40 0 1 58
   21: A80501AC:8121 A90501AC:8122 01 005B5CB0:00000000 01:00001C9D 0000000A
0        0 21226 3 ef7bfa80 120000 40 0 1 35


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

