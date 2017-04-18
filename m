From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: IGMP on IPv6
Date: Tue, 18 Apr 2017 13:12:27 -0400
Message-ID: <58F648FB.10606@ti.com>
References: <1479111388-25383-1-git-send-email-liuhangbin@gmail.com>
 <58D29265.1020604@ti.com> <58EFA913.5060604@ti.com>
 <CAM_iQpWYuQdxF0AOEMHRy7BSmxMVUb-7w7OdgYeOKe6atATsFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:54393 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753561AbdDRRMQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:12:16 -0400
In-Reply-To: <CAM_iQpWYuQdxF0AOEMHRy7BSmxMVUb-7w7OdgYeOKe6atATsFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/17/2017 05:38 PM, Cong Wang wrote:
> Hello,
> 
> On Thu, Apr 13, 2017 at 9:36 AM, Murali Karicheri <m-karicheri2@ti.com> wrote:
>> On 03/22/2017 11:04 AM, Murali Karicheri wrote:
>>> This is going directly to the slave Ethernet interface.
>>>
>>> When I put a WARN_ONCE, I found this is coming directly from
>>> mld_ifc_timer_expire() -> mld_sendpack() -> ip6_output()
>>>
>>> Do you think this is fixed in latest kernel at master? If so, could
>>> you point me to some commits.
>>>
>>>
>> Ping... I see this behavior is also seen on v4.9.x Kernel. Any clue if
>> this is fixed by some commit or I need to debug? I see IGMPv6 has some
>> fixes on the list to make it similar to IGMPv4. So can someone clarify this is
>> is a bug at IGMPv6 code or I need to look into the HSR driver code?
>> Since IGMPv4 is going over the HSR interface I am assuming this is a
>> bug in the IGMPv6 code. But since I have not experience with this code
>> can some expert comment please?
>>
> 
> How did you configure your network interfaces and IPv4/IPv6 multicast?
> IOW, how did you reproduce this? For example, did you change your
> HSR setup when this happened since you mentioned
> NETDEV_CHANGEUPPER?
> 
Thanks for responding! Really appreciate.

I didn't set up anything explicitly for IPv4/IPv6 multicast. As part of
my testing, I dump the packets going through the slave interfaces attached
to the hsr interface (for example my Ethernet interfaces eth2 and eth3
are attached to the hsr interface and I dump the packets at the egress
of eth2 and eth3 in my driver along with that at hsr xmit function). As
soon as I create the hsr interface, I see a bunch of packets going directly
through the lower interface, not through the upper one (i.e hsr interface)
and these are of eth_type = 86 dd. Please ignore my reference to 
NETDEV_CHANGEUPPER for now as it was wild guess.

I have not done any debugging, but the WARN_ONCE which I have placed
in the lower level driver looking for eth_type = 86 dd provided the 
above trace. 

-- 
Murali Karicheri
Linux Kernel, Keystone
