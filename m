From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: question about function igmp_stop_timer() in net/ipv4/igmp.c
Date: Tue, 25 Oct 2016 09:13:54 +0800
Message-ID: <580EB1D2.3010309@hisilicon.com>
References: <580DF574.6070905@hisilicon.com> <20161024153200.GM1110@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:48864 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756474AbcJYBQa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 21:16:30 -0400
In-Reply-To: <20161024153200.GM1110@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 2016/10/24 23:32, Andrew Lunn wrote:
> On Mon, Oct 24, 2016 at 07:50:12PM +0800, Dongpo Li wrote:
>> Hello
>>
>> We encountered a multicast problem when two set-top box(STB) join the same multicast group and leave.
>> The two boxes can join the same multicast group
>> but only one box can send the IGMP leave group message when leave,
>> the other box does not send the IGMP leave message.
>> Our boxes use the IGMP version 2.
>>
>> I added some debug info and found the whole procedure is like this:
>> (1) Box A joins the multicast group 225.1.101.145 and send the IGMP v2 membership report(join group).
>> (2) Box B joins the same multicast group 225.1.101.145 and also send the IGMP v2 membership report(join group).
>> (3) Box A receives the IGMP membership report from Box B and kernel calls igmp_heard_report().
>>     This function will call igmp_stop_timer(im).
>>     In function igmp_stop_timer(im), it tries to delete IGMP timer and does the following:
>>         im->tm_running = 0;
>>         im->reporter = 0;
>> (4) Box A leaves the multicast group 225.1.101.145 and kernel calls
>>     ip_mc_leave_group -> ip_mc_dec_group -> igmp_group_dropped.
>>     But in function igmp_group_dropped(), the im->reporter is 0, so the kernel does not send the IGMP leave message.
> 
> RFC 2236 says:
> 
> 2.  Introduction
> 
>    The Internet Group Management Protocol (IGMP) is used by IP hosts to
>    report their multicast group memberships to any immediately-
>    neighboring multicast routers.
> 
> Are Box A or B multicast routers?
Thank you for your comments.
Both Box A and B are IP hosts, not multicast routers.
And the RFC says: IGMP is used by "IP hosts" to report their multicast group membership.

> 
>     Andrew
> 
> .
> 

    Regards,
    Dongpo

.
