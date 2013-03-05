From: =?ISO-8859-1?Q?Sebastian_P=F6hn?= <sebastian.poehn@googlemail.com>
Subject: Re: tipc: MTU discovery
Date: Tue, 5 Mar 2013 17:22:05 +0100
Message-ID: <CAGUzgdLyqett=78cVYYVWi=ZRE_Z4xgp8tB+jRyEeykcPxRjOQ@mail.gmail.com>
References: <CAGUzgdKJ4pPdhx7VkGCGS8CynXgOrxhTu8dZ+s77C+WKrCcCeA@mail.gmail.com>
	<20130305141824.GG15384@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35581 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab3CEQWH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 11:22:07 -0500
Received: by mail-lb0-f174.google.com with SMTP id l12so4874622lbo.5
        for <netdev@vger.kernel.org>; Tue, 05 Mar 2013 08:22:05 -0800 (PST)
In-Reply-To: <20130305141824.GG15384@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I run a DLink DGE-528T (PCI-ID: 1186:4300). Kernel is 2.6.32
There is a dedicated VLAN sitting over the physical device.

I even made some similar observations in a VM environment but I think
this is even a more fragile setup.

Will install ethtool ...

On Tue, Mar 5, 2013 at 3:18 PM, Erik Hugne <erik.hugne@ericsson.com> wr=
ote:
> On Tue, Mar 05, 2013 at 01:43:29PM +0100, Sebastian P=F6hn wrote:
>> State Messages larger than 1500 which as used for the MTU negotiatio=
n
>> do not appear in the TIPC stack. But I am able to seen them entering
>> the correct device.
>> Because of that no reply with the correct max_packet field set can b=
e
>> send and the negotiation will always end up at 1.5k.
>>
>> So my questions are:
>> # Is TIPC meant to detect and use the MTU larger than 1.5k?
> Yes, it should probe and detect MTU's up to ~66k
>
>> # Why are the packets not passed to the TIPC stack?
> TIPC just registers itself as a handler for ETH_P_TIPC through
> dev_add_pack.
> If link mtu probes >1.5k are not passed to TIPC, it sounds to me that=
 the
> NIC driver
> is to blame. What NIC type and kernel version are you running?
>
> Do you see any packet drops in ethtool statistics?
>
> //E
