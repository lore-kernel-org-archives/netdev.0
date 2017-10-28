From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 0/9] net: dsa: define port types
Date: Sat, 28 Oct 2017 13:15:36 +0200
Message-ID: <495d7d53-2c61-7828-07dc-c64c203a2f3e@egil-hjelmeland.no>
References: <833b871f-e9d4-3d3e-70d5-8aaa19b8f045@egil-hjelmeland.no>
 <20171027193709.GA2385@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:37704 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbdJ1LPt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 07:15:49 -0400
In-Reply-To: <20171027193709.GA2385@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Den 27. okt. 2017 21:37, skrev Andrew Lunn:
> On Fri, Oct 27, 2017 at 02:56:51PM +0200, Egil Hjelmeland wrote:
>>> The DSA code currently has 3 bitmaps in the dsa_switch structure:
>>> cpu_port_mask, dsa_port_mask and enabled_port_mask.
>>
>>
>> Hi Vivien
>>
>> First I must apologize to everybody for not replying in-thread. Problem
>> is that I was not subscribed to netdev. But now I am, so I promise it
>> will not happen again :-)
>>
>> So to the point. I think DSA need to keep track of multicast
>> memberships. As it is now, dsa_switch_mdb_add() include
>> the CPU/DSA port(s) in the multicast. But  multicast is never
>> removed from the CPU/DSA port(s).
> 
> Hi Egil
> 
> You should take a look at my patches from a few weeks back. I hope to
> make another version next week. These deal with multicast on the CPU
> port, or better said, the host wanting to receive a multicast group.
> 
>        Andrew
> 

Hi Andrew

I suppose you refer to https://www.spinics.net/lists/netdev/msg453848.html.
That will be great to have for my employer.

Regarding the offload_fwd_mark discussion: I did some experiments
yesterday afternoon on the lan9303 driver.

- Driver add the STP address to the ALR(fdb) pointing to CPU port
- In tag_lan9303.c rcv() set offload_fwd_mark if destination is
   not STP address.

In addition; I found out that my fresh lan9303_xmit_use_arl() is wrong:
Multicast and broadcasts must not be sent via the ALR.

  - use ALR on transmit if bridged and destination is unicast.

Then it looks as if the system is doing the right thing, both for
incomming and outgoing packets. Including STP BPDUs both when
STP is enabled and not.

I will have to test more though when back at office next week.

Egil
