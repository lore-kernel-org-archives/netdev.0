From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB going crazy over ~5Gbit/s (4.12.9, but problem present in
 older kernels as well)
Date: Wed, 13 Sep 2017 10:58:54 -0700
Message-ID: <1505325534.15310.182.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
         <d2aee52fda21d8f668ca012333ef3677@nuclearcat.com>
         <1505319370.15310.169.camel@edumazet-glaptop3.roam.corp.google.com>
         <9b8cdc2b39fdd2d0be7b5f559b2034e7@nuclearcat.com>
         <1505320949.15310.173.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505321747.15310.175.camel@edumazet-glaptop3.roam.corp.google.com>
         <57baf3c3ea2544ed4d53967b7a2d0e36@nuclearcat.com>
         <1505323222.15310.177.camel@edumazet-glaptop3.roam.corp.google.com>
         <5a95e6550a304545fbde95360985c018@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netdev-owner@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:43282 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751112AbdIMR64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 13:58:56 -0400
In-Reply-To: <5a95e6550a304545fbde95360985c018@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-09-13 at 20:35 +0300, Denys Fedoryshchenko wrote:

> Overlimits never appear in HTB as i know, here is simulation on this 
> class that have constant "at least" 1G traffic, i throttled it to 1Kbit 
> to simulate forced drops:
> 
> shapernew ~ # sh /etc/shaper.cfg;sleep 1;tc -s -d class show dev 
> eth3.777 classid 1:111;tc qdisc del dev eth3.777 root
> class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 1Kbit 
> ceil 1Kbit linklayer ethernet burst 31280b/1 mpu 0b cburst 31280b/1 mpu 
> 0b level 0
>   Sent 134350019 bytes 117520 pkt (dropped 7819, overlimits 0 requeues 0)
>   backlog 7902126b 4976p requeues 0
>   lended: 86694 borrowed: 0 giants: 0
>   tokens: -937500000 ctokens: -937500000
> 

Oh right, I am using a local patch for this. Time to upstream :/
