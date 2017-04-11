From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 13:42:25 -0400 (EDT)
Message-ID: <20170411.134225.398046538225438175.davem@davemloft.net>
References: <1491894172.31620.2.camel@sipsolutions.net>
        <9a68aa01-474c-7054-30c2-473ee1250abe@cumulusnetworks.com>
        <20170411173143.GA1899@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, johannes@sipsolutions.net,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        jhs@mojatatu.com, jbenc@redhat.com, jiri@resnulli.us
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdDKRm1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 13:42:27 -0400
In-Reply-To: <20170411173143.GA1899@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 11 Apr 2017 19:31:43 +0200

> On Tue, Apr 11, 2017 at 08:25:57AM -0600, David Ahern wrote:
>> On 4/11/17 1:02 AM, Johannes Berg wrote:
>> > On Tue, 2017-04-11 at 08:59 +0200, Pablo Neira Ayuso wrote:
>> >> CAP_ACK means: trim off the payload that the netlink error message
>> >> is embedding, just like ICMP error does.
>> >>
>> >> What is exactly your concern? If the user explicitly requests this
>> >> via socket option for this socket, then we're expecting they do the
>> >> right handling for what they're asking for.
>> > 
>> > I think David's concern was that when you want to parse the ACK in a
>> > library (or application), you may not easily know if the application
>> > (or library) requested capping.
>> 
>> exactly.
> 
> Then, the library needs to be extended to enable this handling to
> modify the way it needs to handle errors, together with the
> setsockopt().

That's my take on this.

If there are libraries where there is a disconnect between the thing
that controls the sending of the netlink request from the processing
of the netlink response, that really is their problem to work out.

If they wish to support extended ACK reports, they will need to
sort those details out.

If there is sharing of a newlink socket between different libraries,
each wanting to operate in a different mode, that isn't all that
reasonable to me.  Often libraries can't even agree on whether they
want to use a socket fd in non-blocking vs. blocking mode.

David, if you have a specific case where it's absolutely impossible
to resolve this when the library is converted to support extended
ACKs, please mention it.

Thanks.
