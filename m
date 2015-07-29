From: Kirill Tkhai <ktkhai@odin.com>
Subject: Re: [PATCH] net_sched: restore "mpu xxx" handling
Date: Wed, 29 Jul 2015 17:39:47 +0300
Message-ID: <55B8E5B3.4010608@odin.com>
References: <55B8B807.4030102@odin.com> <1438175068.20182.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, <tkhai@ya.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:52866 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbbG2OkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 10:40:02 -0400
In-Reply-To: <1438175068.20182.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29.07.2015 16:04, Eric Dumazet wrote:
> On Wed, 2015-07-29 at 14:24 +0300, Kirill Tkhai wrote:
>> commit 56b765b79 ("htb: improved accuracy at high rates")
>> broke the "mpu xxx" handling.
>>
>> This patch restores the "mpu xxx" handling for htb:
>>
>> # tc class add dev eth0 classid 1:2 parent 1: htb rate 1mbit mpu 0
>> # ping -f -c 1000 10.30.22.52
>> rtt min/avg/max/mdev = 0.156/1.881/2.454/0.175 ms, ipg/ewma 1.908/1.925 ms
>>
>> # tc class change dev eth0 classid 1:2 parent 1: htb rate 1mbit mpu 1000
>> # ping -f -c 1000 10.30.22.52
>> rtt min/avg/max/mdev = 15.352/22.229/38.646/2.212 ms, pipe 3, ipg/ewma 15.999/22.609 ms
> 
> Note this mpu option was completely broken a long time ago with GSO /
> TSO anyway.
> 
> Note sure we really want it in this state ?
> 
> What is your use case ?

It's a way to limit a number of small packets sent from inside container
(virtual enviroment).

Its ethernet card is virtual and it's possible to control the things like TSO,
and to turn it off.

We use that in 2.6.32. Now I'm working with 3.10 and found, that the interface
has been changed. The patch is similar the functionality, which we had before
commit 56b765b79.

Are there another alternatives?

> In any case, correct fix would be in psched_l2t_ns(), otherwise you fix
> htb but not the other qdisc (tbf for that matter)

Sure, I'm agree.
