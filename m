From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tainted warnings with tcp splicing in 3.7.1
Date: Thu, 10 Jan 2013 10:22:21 -0800
Message-ID: <50EF06DD.7070207@hp.com>
References: <F476A81A60AA6B458C3DA58B993EA70A1B8F394A@MUCR10053060111.muc.traviangames.lan> <1357750898.27446.33.camel@edumazet-glaptop> <1357751372.27446.40.camel@edumazet-glaptop> <1357801149.27446.1142.camel@edumazet-glaptop> <20130110072136.GK9943@1wt.eu> <1357831787.27446.2168.camel@edumazet-glaptop> <1357834825.27446.2205.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>,
	Christian Becker <c.becker@traviangames.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:38762 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab3AJSW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 13:22:28 -0500
In-Reply-To: <1357834825.27446.2205.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2013 08:20 AM, Eric Dumazet wrote:
> I also want to thanks Rick, as the latest netperf has splice() support.
>
> Thanks Rick !

You are quite welcome - and thank you for helping me get it to actually 
work :)

Those wishing to try it themselves should grab the top-of-trunk netperf 
bits from http://www.netperf.org/svn/netperf2/trunk .  The use of 
splice() is gated by a test-specific -V option:

raj@tardy:~/netperf2_trunk/src$ ./netperf -t omni -- -d recv -V
OMNI Receive TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
localhost.localdomain () port 0 AF_INET : copy avoidance : demo
Remote      Local       Remote Elapsed Throughput Throughput
Send Socket Recv Socket Send   Time               Units
Size        Size        Size   (sec)
Final       Final
1661688     4194304     16384  10.00   26103.14   10^6bits/s

You should see that "copy avoidance" appearing in the test banner.  It 
will also "take" for things like a migrated TCP_mumble test.  For those 
cases where you don't see a throughput change, enabling CPU utilization 
measurement and looking at that and service demand should show a difference.

happy benchmarking,

rick jones
