From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: HTB going crazy over ~5Gbit/s (4.12.9, but problem present in
 older kernels as well)
Date: Wed, 13 Sep 2017 20:35:41 +0300
Message-ID: <5a95e6550a304545fbde95360985c018@nuclearcat.com>
References: <4cd23914d8cc2cf5caf78cb5654fb245@nuclearcat.com>
 <d2aee52fda21d8f668ca012333ef3677@nuclearcat.com>
 <1505319370.15310.169.camel@edumazet-glaptop3.roam.corp.google.com>
 <9b8cdc2b39fdd2d0be7b5f559b2034e7@nuclearcat.com>
 <1505320949.15310.173.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505321747.15310.175.camel@edumazet-glaptop3.roam.corp.google.com>
 <57baf3c3ea2544ed4d53967b7a2d0e36@nuclearcat.com>
 <1505323222.15310.177.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        netdev-owner@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:56346 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751092AbdIMRfo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 13:35:44 -0400
In-Reply-To: <1505323222.15310.177.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-09-13 20:20, Eric Dumazet wrote:
> On Wed, 2017-09-13 at 20:12 +0300, Denys Fedoryshchenko wrote:
> 
>> For my case, as load increased now, i am hitting same issue (i tried 
>> to
>> play with quantum / bursts as well, didnt helped):
>> 
>> tc -s -d class show dev eth3.777 classid 1:111;sleep 5;tc -s -d class
>> show dev eth3.777 classid 1:111
>> class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 20Gbit
>> ceil 100Gbit linklayer ethernet burst 100000b/1 mpu 0b cburst 
>> 100000b/1
>> mpu 0b level 0
>>   Sent 864151559 bytes 730566 pkt (dropped 15111, overlimits 0 
>> requeues
>> 0)
>>   backlog 73968000b 39934p requeues 0
>>   lended: 499867 borrowed: 0 giants: 0
>>   tokens: 608 ctokens: 121
>> 
> 
> You have drops (and ~40,000 packets in backlog)
> 
> 
>> class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 20Gbit
>> ceil 100Gbit linklayer ethernet burst 100000b/1 mpu 0b cburst 
>> 100000b/1
>> mpu 0b level 0
>>   Sent 1469352160 bytes 1243649 pkt (dropped 42933, overlimits 0 
>> requeues
>> 0)
>>   backlog 82536047b 39963p requeues 0
>>   lended: 810475 borrowed: 0 giants: 0
>>   tokens: 612 ctokens: 122
>> 
>> (1469352160-864151559)/5*8
>> 968320961.60000000000000000000
>> Less than 1Gbit and it's being throttled
> 
> It is not : "overlimits 0"  means this class was not throttled.
Overlimits never appear in HTB as i know, here is simulation on this 
class that have constant "at least" 1G traffic, i throttled it to 1Kbit 
to simulate forced drops:

shapernew ~ # sh /etc/shaper.cfg;sleep 1;tc -s -d class show dev 
eth3.777 classid 1:111;tc qdisc del dev eth3.777 root
class htb 1:111 parent 1:1 leaf 111: prio 0 quantum 50000 rate 1Kbit 
ceil 1Kbit linklayer ethernet burst 31280b/1 mpu 0b cburst 31280b/1 mpu 
0b level 0
  Sent 134350019 bytes 117520 pkt (dropped 7819, overlimits 0 requeues 0)
  backlog 7902126b 4976p requeues 0
  lended: 86694 borrowed: 0 giants: 0
  tokens: -937500000 ctokens: -937500000
