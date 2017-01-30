From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Mon, 30 Jan 2017 11:41:43 -0500 (EST)
Message-ID: <20170130.114143.1357866047815335563.davem@davemloft.net>
References: <20170127215848.GG25829@oracle.com>
        <CAF=yD-KqQdPVn-CFAu3ak+c3NRO9gfT+8UwXXS4eSv9ax0iAnA@mail.gmail.com>
        <20170130162603.GF3590@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemdebruijn.kernel@gmail.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56248 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932355AbdA3Qlz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 11:41:55 -0500
In-Reply-To: <20170130162603.GF3590@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 30 Jan 2017 11:26:03 -0500

> On (01/27/17 19:19), Willem de Bruijn wrote:
>> > other than ax25, are there variable length header protocols out there
>> > without ->validate, and which need the CAP_RAW_SYSIO branch?
>> 
>> I don't know. An exhaustive search of protocols (by header_ops) may be
>> needed to say for sure.
>> 
>> If there are none, then the solution indeed is quite simple.
> 
> 
> I tried to start that exhaustive search, and it can be quite daunting:
> if you are doing this by just code-inspection, it's easy to get
> it wrong.. I havent quite given up yet, but it may be simpler to have
> the drivers support some defensive code against bogus skb's in the
> Tx path (the drivers will know, for sure, what's the min non-paged
> len they need anyway).

I think it's easier to audit all the header_ops than to add defensive
code to 500+ drivers.
