From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Thu, 19 Apr 2012 11:05:49 -0700
Message-ID: <4F9053FD.4060509@hp.com>
References: <1334653608.6226.11.camel@edumazet-laptop> <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com> <1334681204.2472.41.camel@edumazet-glaptop> <1334698722.2472.71.camel@edumazet-glaptop> <1334764184.2472.299.camel@edumazet-glaptop> <CADVnQy=BkhSBHyN2hyBy=_H64oM8sJvyZZfEjK1x7PYzoLv=5w@mail.gmail.com> <1334776707.2472.316.camel@edumazet-glaptop> <1334778707.2472.333.camel@edumazet-glaptop> <alpine.DEB.2.00.1204191401240.735@wel-95.cs.helsinki.fi> <1334835018.2395.66.camel@edumazet-glaptop> <1334841481.2395.175.camel@edumazet-glaptop> <1334843527.2395.182.camel@edumazet-glaptop> <1334844652.2395.187.camel@edumazet-glaptop>  <4F904955.7070403@hp.com> <1334856306.2395.208.camel@edumazet-glaptop>  <4F904FFE.60703@hp.com> <1334858436.2395.212.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:32909 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197Ab2DSSFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 14:05:52 -0400
In-Reply-To: <1334858436.2395.212.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> That or bare ACKs have to be excluded from the overhead checks somehow I
>> guess, or there be more aggressive copying into smaller buffers.
>>
>
> Nope, we need a limit or risk OOM if a malicious peer send ACK flood ;)

Well, there is that...

>
> To be clear, if I change the tcp_rmem[1] from 87380 to big value, I no
> longer have ACK drops, but still poor performance, I am still
> investigating.

What happens if you set net.core.[rw]mem_max to 4 MB and then use 
something like -s 1M -S 1M in netperf?

netperf -t TCP_STREAM -H <remote> -- -s 1M -S 1M -m 64K

(or -m 16K if you want to keep the send size the same as your previous 
tests...)

rick
