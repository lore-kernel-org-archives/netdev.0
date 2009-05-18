From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: bond + tc regression ?
Date: Mon, 18 May 2009 08:51:27 +0000
Message-ID: <20090518085127.GA6636@ff.dom.local>
References: <1242586001.2711.11.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:52203 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbZERIvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 04:51:32 -0400
Received: by yx-out-2324.google.com with SMTP id 3so1897348yxj.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 01:51:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1242586001.2711.11.camel@hazard2.francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-2009 20:46, Vladimir Ivashchenko wrote:
>>> All child classes have smaller bursts than the parent. However, there are
>>> two sub-classes which have ceil at 70% of parent, e.g. ~500mbit each. I
>>> don't know HTB internals, perhaps these two classes make the parent class
>>> overstretch itself.
>> As i remember important to keep sum of child rates lower or equal parent rate.
>> Sure ceil of childs must not exceed ceil of parent.
>> Sometimes i had mess, when i tried to play with quantum value. After all that 
>> i switched to HFSC which works for me flawlessly. Maybe we should give more 
>> attention to HTB problem with high speeds and help kernel developers spot 
>> problem, if there is any.
> 
> In case of HFSC my problem is even worse. With 775mbit ceiling
> configured it is passing over 900mbit in reality. Moreover not having
> statistics for parent classes makes it difficult to troubleshoot :( I'm
> 100% sure that it is 900 mbps, I see this on the switch.
> 
> Attached is "tc -s -d class show dev bond0" output.
> 
> To calculate total traffic rate:
> 
> $ cat hfsc-stat.txt | grep rate | grep Kbit | sed 's/Kbit//' | awk
> '{ a=a+$2; } END { print a; }'
> 906955
> 
> Did I misconfigure something ?... How can hfsc go above 775mbit when
> everything goes via class 1:2 with 775mbit rate & ul ?

Maybe... It's a lot of checking - it seems test cases could be simpler
to show the real problem. Anyway, it looks like the sum of m2 of 1:2
children is more than 775Mbit.


>>> By the way, I experience the same "overstretching" with hfsc. In any case,
>>> I prefer HTB because it reports statistics of parent classes, unlike hfsc.
>> Sometimes it happen when some offloading enabled on devices.
>> Check ethtool -k device
> 
> Offload parameters for eth0:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp segmentation offload: off
> udp fragmentation offload: off

Current versions of ethtool should show "generic segmentation offload"
too.

I hope you've read the nearby thread "HTB accuracy for high speed",
which explains at least partially some problems/bugs, and maybe you'll
try some patches too (at last one of them addresses the problem you've
reported). Anyway, if you don't find hfsc is better for you I'd be
more interested in tracking this on htb test cases yet.

Thanks,
Jarek P.
