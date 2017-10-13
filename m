From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net/smc: add SMC rendezvous protocol
Date: Thu, 12 Oct 2017 23:06:34 -0700 (PDT)
Message-ID: <20171012.230634.24414822731374394.davem@davemloft.net>
References: <20171011.140652.272274136617199385.davem@davemloft.net>
        <b37b38df-cbb8-ca86-d460-9d3ec7acc2c6@linux.vnet.ibm.com>
        <20171012111429.GG26835@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ubraun@linux.vnet.ibm.com, netdev@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, hwippel@linux.vnet.ibm.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753713AbdJMGGf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 02:06:35 -0400
In-Reply-To: <20171012111429.GG26835@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 12 Oct 2017 13:14:29 +0200

> Ursula Braun <ubraun@linux.vnet.ibm.com> wrote:
>> On 10/11/2017 11:06 PM, David Miller wrote:
>> > From: Ursula Braun <ubraun@linux.vnet.ibm.com>
>> > Date: Tue, 10 Oct 2017 16:14:19 +0200
>> > 
>> >> The goal of this patch is to leave common TCP code unmodified. Thus,
>> >> it uses netfilter hooks to intercept TCP SYN and SYN/ACK
>> >> packets. For outgoing packets originating from SMC sockets, the
>> >> experimental option is added. For inbound packets destined for SMC
>> >> sockets, the experimental option is checked.
>> > 
>> > I think this really isn't going to pass.
>> > 
>> > It's a user experience nightmare when the kernel inserts and
>> > deletes filtering rules outside of what the user configures
>> > on their system.
> 
> It depends if the hook is passive or not (i.e. mangles
> payload/metadata or returns verdict other than NF_ACCEPT).
> 
> OUTPUT hook added here is not passive as it mangles tcp options.
> 
>> > This approach was also considerd for ipv6 ILA, and the same
>> > pushback was given.
> 
> ahem.
> net/ipv6/ila/ila_xlat.c:   err = nf_register_net_hooks(net, ila_nf_hook_ops,

My bad, I thought we had decided against that.

Oh well.
