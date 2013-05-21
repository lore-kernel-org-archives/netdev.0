From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: [PATCH net]  vxlan: revert per-vxlan port
Date: Mon, 20 May 2013 19:53:59 -0700
Message-ID: <519AE1C7.5060807@gmail.com>
References: <20130520103017.054ae605@nehalam.linuxnetplumber.net> <OFECE722DE.3DBEE821-ON85257B71.00610478-85257B71.006456B5@us.ibm.com> <20130520113000.0057ce90@nehalam.linuxnetplumber.net> <519AB8F0.7060003@gmail.com> <20130520171304.06c6ed00@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:50833 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515Ab3EUCyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 22:54:02 -0400
In-Reply-To: <20130520171304.06c6ed00@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/20/2013 5:13 PM, Stephen Hemminger wrote:
> On Mon, 20 May 2013 16:59:44 -0700
> Sridhar Samudrala <samudrala.sridhar@gmail.com> wrote:
>
>> On 5/20/2013 11:30 AM, Stephen Hemminger wrote:
>>> On Mon, 20 May 2013 14:15:59 -0400
>>> David Stevens <dlstevens@us.ibm.com> wrote:
>>>
>>>>> From: Stephen Hemminger <stephen@networkplumber.org>
>>>>    
>>>>> \This commit 823aa873bc782f1c51b1ce8ec6da7cfcaf93836e
>>>>> Author: stephen hemminger <stephen@networkplumber.org>
>>>>> Date:   Sat Apr 27 11:31:57 2013 +0000
>>>>>
>>>>>       vxlan: allow choosing destination port per vxlan
>>>>>
>>>>> is broken revert it. The change allowed setting per port for transmit
>>>>> but did not add additional listening sockets, which made any vxlan's
>>>>> defined with non-default port send only.
>>>> This allows you to specify a different default port for
>>>> transmits, which is what you want to do if your own instance
>>>> of VXLAN is the odd one. I don't see any requirement for multiple
>>>> listen ports for that to be useful, since those sending to you
>>>> can have complete fdb tables even if the local instance doesn't
>>>> and relies on the default. Not to mention using an agent to
>>>> fill the fdb triggered by packets sent to the default, so the
>>>> receiver is not necessarily even a VXLAN instance. The receiver
>>>> side and transmit side ports can be completely independent of
>>>> each other, as in any other client-server system.
>>> Vxlan's are a weird beast. They can be viewed as either bridge like
>>> entities or tunnel like entities. I view them more as bridge type
>>> devices where user configures two hosts with equivalent values and
>>> they learn about each other. In that case the code in 3.10 is broken;
>>> but the version with the learning in net-next works.
>>>
>>> Your view is that VXLAN's are more like tunnels, where each host
>>> has static entries to know about every other host. In that mode,
>>> 3.10 is useable, but the same effect can be had by defining static
>>> neighbour entries.
>> how can we send to a different dst port using static neighbor entries?
>>
>> Thanks
>> Sridhar
> It is part of this commit in 3.10 already.
>
> commit 6681712d67eef14c4ce793561c3231659153a320
> Author: David Stevens <dlstevens@us.ibm.com>
> Date:   Fri Mar 15 04:35:51 2013 +0000
>
>      vxlan: generalize forwarding tables
>      
>      This patch generalizes VXLAN forwarding table entries allowing an administrator
>      to:
>          1) specify multiple destinations for a given MAC
>          2) specify alternate vni's in the VXLAN header
>          3) specify alternate destination UDP ports
>          4) use multicast MAC addresses as fdb lookup keys
>          5) specify multicast destinations
>          6) specify the outgoing interface for forwarded packets
>      
>
OK. I am aware of specifying dst port via static fdb(forwarding table) 
entries.
I was confused when you said neighbor entries.

Thanks
Sridhar
