From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: RFC: sk leak in sock_graft?
Date: Tue, 27 Jun 2017 15:59:21 -0400
Message-ID: <20170627195921.GA9171@oracle.com>
References: <20170624130827.GD6901@oracle.com>
 <20170627.153816.46774843898605825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38071 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753647AbdF0T7c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 15:59:32 -0400
Content-Disposition: inline
In-Reply-To: <20170627.153816.46774843898605825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (06/27/17 15:38), David Miller wrote:
> 
> It could simply be the case that rds-tcp is the first setup that
> created that situation where there is a parent->sk already.

Possibly, I noticed that other callers call sock_create_lite()
and I dont know the history here - this seems to have been
the case from day-1 of rds-tcp. (and I dread changing 
rds_tcp_accept_kern() to do this, because then every module unload
would need to go and check if sock->sk is non-null first, before
cleaning it up

> Why does rds-tcp need to call sock_graft() without those invariants
> met?

It would certainly help to declare "dont use sock_creeate_kern()
if you are going to accept on this socket"- I dont see that being 
mandated anywhere.

It would also help to have a BUG_ON(parent->sk) or at least a
WARN_ON(parent->sk) in sock_graft, before unilaterally assigning 
it to the new sk. 

--Sowmini
