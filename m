From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: mlx4: dropping multicast packets at promisc leave
Date: Thu, 20 Sep 2012 16:21:56 +0300
Message-ID: <505B1874.3040904@mellanox.com>
References: <505A66CC.8010701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:35665 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753513Ab2ITNX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 09:23:26 -0400
In-Reply-To: <505A66CC.8010701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/09/2012 03:43, Marcelo Ricardo Leitner wrote:
> I have a report that our mlx4 driver (RHEL 6.3) is dropping multicast 
> packets when NIC leaves promisc mode. It seems this is being cause due 
> to the new steering mode that took place near by commit 
> 1679200f91da6a054b06954c9bd3eeed29b6731f. As it seems, the new 
> steering mode needs more commands/time to leave the promisc mode, 
> which may be leading to packet drops.

Marcelo,

The commit you point on below 6d19993 "net/mlx4_en: Re-design multicast 
attachments flow" makes sure to avoid
doing extra firmware comments and not leave a window in time where 
"correct" addresses are not attached. Its hard to say what's the case on 
that RHEL 6.3 system, it would be very helpful through if you manage to 
reproduce the problem on an upstream kernel -- BTW you didn't say on 
which kernel you are  trying to reproduce  this, note that upstream has 
also commit 60d31c1475f2 "net/mlx4_core: Looking for promiscuous entries 
on the correct port" (reported by you...) , so if somehow this commit 
makes the diff you could use it also on their system.

> It takes 300ms to perform the change there against my 600us. Hitting 
> something like tcpdump -c 10 in a loop helps triggering it.

Do you have any insight for this huge difference?

Or.
