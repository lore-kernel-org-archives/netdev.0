From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH v2 4/5] ipvlan: protect addresses with internal spinlock
Date: Fri, 10 Jul 2015 15:08:39 +0300
Message-ID: <559FB5C7.8070408@yandex-team.ru>
References: <20150703125132.24121.50592.stgit@buzz> <20150703125840.24121.91556.stgit@buzz> <CAF2d9jipwzVPNcaiQduPkDyoy3OXQG4UW=VB4HyVPjyrU2bU1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:52671 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754781AbbGJMIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 08:08:45 -0400
In-Reply-To: <CAF2d9jipwzVPNcaiQduPkDyoy3OXQG4UW=VB4HyVPjyrU2bU1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.07.2015 07:05, Mahesh Bandewar wrote:
> On Fri, Jul 3, 2015 at 5:58 AM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>> Inet6addr notifier is atomic and runs in bh context without RTNL when
>> ipv6 receives router advertisement packet and performs autoconfiguration.
>>
>> This patch adds ipvl_port->addr_lock and helpers: ipvlan_addr_lock_bh,
>> ipvlan_addr_unlock_bh for protecting ipvlan addresses and hash table.
>>
> Frankly I'm not comfortable adding spin-locks all over. I think any
> config that mostly takes place with RTNL makes sense but this
> inet6addr needs to be thought through and implanting spin-locks in
> IPvlan is a work-around for a problem some where else.
> Why can't a work-queue that takes RTNL to call inet6addr-notifier be
> implemented when called from bh?

We already have that work: ipv6 DAD. In v1 patchset was a patch
which moves inet6addr-notifier into it and makes it blockable:

http://www.spinics.net/lists/netdev/msg329017.html

But David Miller objected.

I'm ok with any solution: when spinlock nests inside locked RTNL it
never spins in most cases.

>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> ---
>>   drivers/net/ipvlan/ipvlan.h      |   11 +++++++++++
>>   drivers/net/ipvlan/ipvlan_core.c |    2 --
>>   drivers/net/ipvlan/ipvlan_main.c |   33 ++++++++++++++++++++++++++++++---
>>   3 files changed, 41 insertions(+), 5 deletions(-)
>>
> [snip]
>


-- 
Konstantin
