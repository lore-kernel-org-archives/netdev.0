From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH net-next v2] net: Add sysctl to toggle early demux for tcp
 and udp
Date: Thu, 09 Mar 2017 22:26:10 -0700
Message-ID: <674d67f5d76f761f3e872dff274a8bda@codeaurora.org>
References: <1489116660-4244-1-git-send-email-subashab@codeaurora.org>
 <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev-owner@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49072 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750936AbdCJF0O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 00:26:14 -0500
In-Reply-To: <CALx6S360Y3tmKMHVMUEuRKCskuwXi+9JBfce6WiSpko1sHj=Yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-09 20:42, Tom Herbert wrote:
> On Thu, Mar 9, 2017 at 7:31 PM, Subash Abhinov Kasiviswanathan
> <subashab@codeaurora.org> wrote:
>> Certain system process significant unconnected UDP workload.
>> It would be preferrable to disable UDP early demux for those systems
>> and enable it for TCP only.
>> 
> Presumably you want this for performance reasons. Can you provide some
> before and after numbers?

Hi Tom

We are working on UDPv6 performance issues seen on an Android ARM64 
system.
Adding an early demux handler (link below) for it helped to increase 
performance
(800Mbps -> 870Mbps). This helps because Android statistics rules do 
multiple
socket lookup when no socket is associated with the skb.

https://www.mail-archive.com/netdev@vger.kernel.org/msg157003.html

Eric mentioned that server loads usually see more unconnected load and 
he
preferred to turn off early demux for UDP, hence this patch. I don't 
have numbers
for unconnected loads as of now though.
