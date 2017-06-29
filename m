From: David Miller <davem@davemloft.net>
Subject: Re: RFC: sk leak in sock_graft?
Date: Thu, 29 Jun 2017 12:46:33 -0400 (EDT)
Message-ID: <20170629.124633.1294861014856097794.davem@davemloft.net>
References: <20170627.153816.46774843898605825.davem@davemloft.net>
        <20170627195921.GA9171@oracle.com>
        <20170627204529.GE9171@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752841AbdF2Qqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 12:46:35 -0400
In-Reply-To: <20170627204529.GE9171@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 27 Jun 2017 16:45:29 -0400

> On (06/27/17 15:59), Sowmini Varadhan wrote:
>> > Why does rds-tcp need to call sock_graft() without those invariants
>> > met?
>> 
>> It would certainly help to declare "dont use sock_creeate_kern()
>> if you are going to accept on this socket"- I dont see that being 
>> mandated anywhere.
> 
> I can look into getting rds_tcp_accept_one also calling sock_create_lite
> like every other caller, (though I may not get to this for another week,
> due to travel), but the code in sock_graft() doesnt look right either. 
> 
> At the very least, there needs to be a WARN_ON(parent->sk) there,
> to provide a gentle dope-slap for the next slob that stumbles on this
> type of leak.

In the accept case it is, if anything, very wasteful.

This is because you allocate a sock and then immediately free it up.

I would say mimick the logic of sys_accept4() and just use
sock_alloc() to allocate the struct socket without a struct sock.
Or, as you say, use sock_create_lite() or a similar helper.
