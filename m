From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Tue, 6 Aug 2013 21:47:01 +0200
Message-ID: <CA+icZUVmokQ1fKmtbuPyp7f5Z2wdFYfjG5HCAm4Kue7efyKV8w@mail.gmail.com>
References: <CA+icZUX8OcTSOABO6Nbz5R6_5-m39rsYOpDqYBA7hf8LFvJLLA@mail.gmail.com>
	<1375797260.8219.21.camel@jlt4.sipsolutions.net>
	<CA+icZUUAJ25QybqHvxz7eubSLH6YuNjcc5zyU2O5Xi9vevMGkw@mail.gmail.com>
	<1375800617.8219.23.camel@jlt4.sipsolutions.net>
	<CA+icZUVbKpyuke6PRg3-60gOggsTb=3cNRz3Sy0RmvcZSuPaNw@mail.gmail.com>
	<1375801059.8219.24.camel@jlt4.sipsolutions.net>
	<CA+icZUXrRsXfeW9hqxTMkKW4TdNSBH-zE8-zX2Rd7HTAx5MvqQ@mail.gmail.com>
	<CA+icZUWijPJmNoqE22Msqcn7tRot3SB3e=KujMM7JNd-Om-oOw@mail.gmail.com>
	<1375802297.8219.25.camel@jlt4.sipsolutions.net>
	<CA+icZUVCFOS6SHonEqzaJyWCGCU4nqqGjBN0VbmV-=OoM+deZg@mail.gmail.com>
	<CA+icZUVuOqdZUGy2ALAF1CehOqYdr7rtEsXhqNvDtYEns2BuRQ@mail.gmail.com>
	<1375802993.8219.26.camel@jlt4.sipsolutions.net>
	<CA+icZUW6P9Z_7z+o+z=qBWSFzyU8tgtY0ou+rmLcEzWbn94OXA@mail.gmail.com>
	<CA+icZUW7LVzg7sM3O-w5oQpeaj=CT6MS6Q7cRZ1qK0h-Z4wZuw@mail.gmail.com>
	<1375804998.8219.27.camel@jlt4.sipsolutions.net>
	<CA+icZUVRgVfXUdJ1xoaN=nciqZDhV-f6EbH+6DS7HAh+My65oQ@mail.gmail.com>
	<CA+icZUUmQbovkwXcdEp6eu=WJkiuiyO8nDVwCHFUuPDbJqU7Kg@mail.gmail.com>
	<CA+icZUV++2+OG=P1SVbNrpHPLyzrfFX0eu8NHrd0nPjkPDUOtQ@mail.gmail.com>
	<CA+icZUXpZaHu-FjR6FGnbkG0XEkiukEgYYbDmrSjdqNz4rWCNg@mail.gmail.com>
	<1375816128.8219.28.camel@jlt4.sipsolutions.net>
	<CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com>
	<1375816715.8219.29.camel@jlt4.sipsolutions.net>
	<CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:60239 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756326Ab3HFTrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 15:47:04 -0400
In-Reply-To: <CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 6, 2013 at 9:32 PM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Tue, Aug 6, 2013 at 9:18 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
>> On Tue, 2013-08-06 at 21:14 +0200, Sedat Dilek wrote:
>>> On Tue, Aug 6, 2013 at 9:08 PM, Johannes Berg <johannes@sipsolutions.net> wrote:
>>> > On Tue, 2013-08-06 at 20:35 +0200, Sedat Dilek wrote:
>>> >
>>> >> Attached is a diff comparing all new commits in next-20130805.
>>> >> If one of the commits smells bad to you, please let me know.
>>> >
>>> > Out of that list, only the af_packet changes would seem to have any
>>> > impact on wireless at all.
>>> >
>>>
>>> git-bisecting... 2 steps to go...
>>>
>>> This one is bad... "af_packet: simplify VLAN frame check in packet_snd"
>>>
>>> http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c483e02614551e44ced3fe6eedda8e36d3277ccc
>>
>> That seems weird, does reverting it fix it?
>>
>
> [ TO Phil Sutter ]
>
> This was 3/3 of af_packet patches :-).
>
> So, the culprit commit is...
>
> 0f75b09c798ed00c30d7d5551b896be883bc2aeb is the first bad commit
> commit 0f75b09c798ed00c30d7d5551b896be883bc2aeb
> Author: Phil Sutter <phil@nwl.cc>
> Date:   Fri Aug 2 11:37:39 2013 +0200
>
>     af_packet: when sending ethernet frames, parse header for skb->protocol
>
>     This may be necessary when the SKB is passed to other layers on the go,
>     which check the protocol field on their own. An example is a VLAN packet
>     sent out using AF_PACKET on a bridge interface. The bridging code checks
>     the SKB size, accounting for any VLAN header only if the protocol field
>     is set accordingly.
>
>     Note that eth_type_trans() sets skb->dev to the passed argument, so this
>     can be skipped in packet_snd() for ethernet frames, as well.
>
>     Signed-off-by: Phil Sutter <phil@nwl.cc>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> :040000 040000 af403a20a321517f6cfb51d2e22c17ca5a60e947
> 1f302ebd62a87b9e874a3e61203499e17d6fce3c M      net
>
> - Sedat -

[ net/packet/af_packet.c ]
...
#include <linux/if_arp.h>

$ find include/ -name if_arp.h
include/uapi/linux/if_arp.h
include/linux/if_arp.h

$ LC_ALL=C ll include/uapi/linux/if_arp.h include/linux/if_arp.h
-rw-r--r-- 1 wearefam wearefam 1560 Jul 11 19:42 include/linux/if_arp.h
-rw-r--r-- 1 wearefam wearefam 6344 Jul 26 12:36 include/uapi/linux/if_arp.h

$ grep ARPHRD_ETHER include/linux/if_arp.h include/uapi/linux/if_arp.h
include/uapi/linux/if_arp.h:#define ARPHRD_ETHER        1
 /* Ethernet 10Mbps              */

Wrong include?

- Sedat -
