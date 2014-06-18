From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Broken IPv6 multicast binding
Date: Wed, 18 Jun 2014 00:43:59 -0700
Message-ID: <1403077439.4559.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <539FC019.4010804@acfr.usyd.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: James Ward <j.ward@acfr.usyd.edu.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:63753 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328AbaFRHoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 03:44:04 -0400
Received: by mail-we0-f176.google.com with SMTP id u56so397716wes.7
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 00:44:02 -0700 (PDT)
In-Reply-To: <539FC019.4010804@acfr.usyd.edu.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-17 at 14:12 +1000, James Ward wrote:
> My colleagues and I have uncovered what we believe is a bug around 
> multicast IPv6 introduced to the kernel recently.
> 
> When more than one socket is bound to different multicast group 
> addresses on the same interface and port, only the last bound socket 
> will receive packets sent to it.
> 
> I have bisected the kernel and identified that commit efe4208f47f907  - 
> https://github.com/torvalds/linux/commit/efe4208f47f907
> was the one that introduced this behaviour. Prior commits behave as 
> expected.
> 
> Attached are two demonstrations of the behaviour.
> 
> C:
> Run "mcreceive6 ff15::1 14678 0"
> Run "mcreceive6 ff15::2 14678 0"
> Run "mcsend6 ff15::1 14678"
> Run "mcsend6 ff15::2 14678"
> 
> Expected: all messages typed into both mcsend6 instances will be echoed 
> to corresponding mcreceive6 instances.
> Actual: only messages sent to ff15::2 are echoed. Messages sent to 
> ff15::1 are not echoed.
> Killing mcreceive6 on ff15::2 will mean messages on ff15::1 are received 
> again.
> 
> Python:
> Run "test_multicast.py"
> Test involving subscription to multiple groups fails.
> 
> James
> 

Hmm... next time you find a regression caused by a particular commit,
make sur to CC patch author, instead of various people found in
MAINTAINERS.

I believe this problem is fixed by commit
3bfdc59a6c24608ed23e903f670aaf5f58c7a6f3
("ipv6: Fix regression caused by efe4208 in udp_v6_mcast_next()")

Thanks
