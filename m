From: =?ISO-8859-1?Q?Sebastian_P=F6hn?= <sebastian.poehn@googlemail.com>
Subject: Re: tipc: MTU discovery
Date: Wed, 6 Mar 2013 10:50:15 +0100
Message-ID: <CAGUzgdLeQD3DMfWtYXphn=P9izoAnbwxBuNdaDcBDS7DFkfYTA@mail.gmail.com>
References: <CAGUzgdKJ4pPdhx7VkGCGS8CynXgOrxhTu8dZ+s77C+WKrCcCeA@mail.gmail.com>
	<20130305141824.GG15384@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:48928 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756165Ab3CFJuQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 04:50:16 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so5761765pbc.25
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 01:50:15 -0800 (PST)
In-Reply-To: <20130305141824.GG15384@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is actually cause by the NIC. It is dropping everything larger than
MTU 1500 on the RX side. But TX is working ...

So I'll gonna do it like always:
If the SW does not work, change the HW

Thanks for the hint

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
> TIPC just registers itself as a handler for ETH_P_TIPC through dev_ad=
d_pack.
> If link mtu probes >1.5k are not passed to TIPC, it sounds to me that=
 the NIC driver
> is to blame. What NIC type and kernel version are you running?
>
> Do you see any packet drops in ethtool statistics?
>
> //E
