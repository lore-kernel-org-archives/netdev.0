From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Mon, 15 Dec 2008 13:23:08 +0100
Message-ID: <49464C2C.6030009@trash.net>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <20081211.203243.124017657.davem@davemloft.net> <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr> <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu> <alpine.LNX.1.10.0812141905490.10355@fbirervta.pbzchgretzou.qr> <alpine.DEB.2.00.0812142056520.2621@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>,
	David Miller <davem@davemloft.net>, ajax@redhat.com,
	linux-kernel@vger.kernel.org, davej@redhat.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.0812142056520.2621@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jozsef Kadlecsik wrote:
> On Sun, 14 Dec 2008, Jan Engelhardt wrote:
> 
>>> In a >normal< system one usually does not use raw sockets. So if a root 
>>> process do use raw socket, at least netfilter sends a notification and 
>>> there's a chance that someone take notice it by checking the kernel logs.
>>> [...]
>>> But should we remove them due to nuisances on >test< systems?
>>>
>>> Rather make it a kernel compile option but do not remove.
>> This warning is in the conntrack calling code. Iff you play with
>> raw sockets and do something wrong, the generic network code
>> should barf IMHO, not nf_conntrack, and not [nf_conntrack_ipv4 only].
> 
> It is not about doing something wrong at using raw sockets - it's about 
> using raw sockets.
> 
> I'm not quite convinced the generic network code should warn about raw 
> sockets. I believe it belongs to the security-related subsystems - 
> netfilter and (or) the security frameworks. [But as netfilter is much more 
> widely used, the 'or' is just theoretical.)

I agree that it doesn't belong to the generic networking code.
But the way its handled in netfilter is far from perfect as well.
Currently multiple modules will spam the ringbuffer repeatedly,
but offer no possibility to change anything in the behaviour of
how these packets are treated. Unfortunately we can't handle this
in the ruleset (which is exactly the reason why we're spamming
the ringbuffer), so how about we add a module option controlling
how to treat those packets and remove the printk?

In the case of conntrack I would even argue that the message
makes no sense at all since tracking doesn't matter as long as
the state isn't used. And for that the table code can warn or
offer controls.


