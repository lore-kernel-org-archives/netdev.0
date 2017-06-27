From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: RFC: sk leak in sock_graft?
Date: Tue, 27 Jun 2017 16:45:29 -0400
Message-ID: <20170627204529.GE9171@oracle.com>
References: <20170624130827.GD6901@oracle.com>
 <20170627.153816.46774843898605825.davem@davemloft.net>
 <20170627195921.GA9171@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17199 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753511AbdF0Upe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 16:45:34 -0400
Content-Disposition: inline
In-Reply-To: <20170627195921.GA9171@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (06/27/17 15:59), Sowmini Varadhan wrote:
> > Why does rds-tcp need to call sock_graft() without those invariants
> > met?
> 
> It would certainly help to declare "dont use sock_creeate_kern()
> if you are going to accept on this socket"- I dont see that being 
> mandated anywhere.

I can look into getting rds_tcp_accept_one also calling sock_create_lite
like every other caller, (though I may not get to this for another week,
due to travel), but the code in sock_graft() doesnt look right either. 

At the very least, there needs to be a WARN_ON(parent->sk) there,
to provide a gentle dope-slap for the next slob that stumbles on this
type of leak.

--Sowmini
