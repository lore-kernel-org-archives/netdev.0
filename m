From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: IGMP on IPv6
Date: Tue, 18 Apr 2017 15:37:19 -0700
Message-ID: <CAM_iQpWJ_oPSWV-PBeBGj5LoddMHTmrimLbViXLJ-VKR21e4mQ@mail.gmail.com>
References: <1479111388-25383-1-git-send-email-liuhangbin@gmail.com>
 <58D29265.1020604@ti.com> <58EFA913.5060604@ti.com> <CAM_iQpWYuQdxF0AOEMHRy7BSmxMVUb-7w7OdgYeOKe6atATsFQ@mail.gmail.com>
 <58F648FB.10606@ti.com> <58F64ADB.8040900@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:36486 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752118AbdDRWhl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 18:37:41 -0400
Received: by mail-wr0-f174.google.com with SMTP id c55so4119122wrc.3
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 15:37:40 -0700 (PDT)
In-Reply-To: <58F64ADB.8040900@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 18, 2017 at 10:20 AM, Murali Karicheri <m-karicheri2@ti.com> wrote:
> On 04/18/2017 01:12 PM, Murali Karicheri wrote:
>> On 04/17/2017 05:38 PM, Cong Wang wrote:
>>> Hello,
>>>
>>> On Thu, Apr 13, 2017 at 9:36 AM, Murali Karicheri <m-karicheri2@ti.com> wrote:
>>>> On 03/22/2017 11:04 AM, Murali Karicheri wrote:
>>>>> This is going directly to the slave Ethernet interface.
>>>>>
>>>>> When I put a WARN_ONCE, I found this is coming directly from
>>>>> mld_ifc_timer_expire() -> mld_sendpack() -> ip6_output()
>>>>>
>>>>> Do you think this is fixed in latest kernel at master? If so, could
>>>>> you point me to some commits.
>>>>>
>>>>>
>>>> Ping... I see this behavior is also seen on v4.9.x Kernel. Any clue if
>>>> this is fixed by some commit or I need to debug? I see IGMPv6 has some
>>>> fixes on the list to make it similar to IGMPv4. So can someone clarify this is
>>>> is a bug at IGMPv6 code or I need to look into the HSR driver code?
>>>> Since IGMPv4 is going over the HSR interface I am assuming this is a
>>>> bug in the IGMPv6 code. But since I have not experience with this code
>>>> can some expert comment please?
>>>>
>>>
>>> How did you configure your network interfaces and IPv4/IPv6 multicast?
>>> IOW, how did you reproduce this? For example, did you change your
>>> HSR setup when this happened since you mentioned
>>> NETDEV_CHANGEUPPER?
>>>
>> Thanks for responding! Really appreciate.
>>
>> I didn't set up anything explicitly for IPv4/IPv6 multicast. As part of
>> my testing, I dump the packets going through the slave interfaces attached
>> to the hsr interface (for example my Ethernet interfaces eth2 and eth3
>> are attached to the hsr interface and I dump the packets at the egress
>> of eth2 and eth3 in my driver along with that at hsr xmit function). As
>> soon as I create the hsr interface, I see a bunch of packets going directly
>> through the lower interface, not through the upper one (i.e hsr interface)
>> and these are of eth_type = 86 dd. Please ignore my reference to
>> NETDEV_CHANGEUPPER for now as it was wild guess.

OK. Note: I know nothing about HSR, I assume it is similar to bonding
in your case?

>>
>> I have not done any debugging, but the WARN_ONCE which I have placed
>> in the lower level driver looking for eth_type = 86 dd provided the
>> above trace.
>>
> Here is the command I have used to create the hsr interface...
>
> ip link add name hsr0 type hsr slave1 eth2 slave2 eth3 supervision 45 version 1

Did you assign IPv4 and IPv6 addresses to the HSR master device?
