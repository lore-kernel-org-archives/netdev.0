From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: One way TCP bottleneck over 6 x Gbit tecl aggregated link
Date: Sun, 22 Mar 2015 09:54:54 -0700
Message-ID: <1427043294.25985.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201503210110.48980.wrosner@tirnet.de>
	 <201503220912.39912.wrosner@tirnet.de>
	 <1427020159.25985.43.camel@edumazet-glaptop2.roam.corp.google.com>
	 <201503221614.47994.wrosner@tirnet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Wolfgang Rosner <wrosner@tirnet.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36784 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbCVQy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 12:54:57 -0400
Received: by igbud6 with SMTP id ud6so24455398igb.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 09:54:56 -0700 (PDT)
In-Reply-To: <201503221614.47994.wrosner@tirnet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-03-22 at 16:14 +0100, Wolfgang Rosner wrote:

> Agree. 
> This is why I considered it as a bug.
> 
> But just a sideline, not my main problem.
> And maybe it is even related to my build environment.
> Or to the fact that I call it with full path. or whatever....
> 
> I don't know whether this repo you pointed me
> https://git.kernel.org/cgit/linux/kernel/git/shemminger/iproute2.git/  
> is a bleeding edge developer fork, that is expected to show such fluctuations, 
> or a should-be-stable mainstream one, where such behaviur is not supposed to 
> occur. 
> 
> So if for you, there is reason to worry on this issue, we can try to debug 
> into it. Let me know, and give me instructions for tests, if required.
> 
> 
> 
> 
> 
> However, from my perspective, I'd prefer to return to my real problem:
> 	"One way TCP bottleneck over 6 x Gbit tecl aggregated link"
> 
> If you got lost in the flood of netdev list (I just subscribed, and am really 
> overwhelmed...), I don't mind to send you the info again and even remove the 
> superfluous lines manually for you - see below.
> 
> Do these figure tell you a story?
> Any hint where to look for a bottleneck?
> Presumaly related to some per-TCP-connection ressource?
> 

I see nothing wrong but a single retransmit.


You might be bitten by tcp_metric cache.

check /proc/sys/net/ipv4/tcp_no_metrics_save

(set it to 0, and flush tcp metric cache :

echo 0 >/proc/sys/net/ipv4/tcp_no_metrics_save
ip tcp_metrics flush


Also, not clear why you use jumbo frames with 1Gbit NIC (do not do that,
really), and it seems TSO is disabled on your NIC(s) ????


for dev in eth0 eth1 eth2 eth3 ....
do
 ethtool -k $dev
done
