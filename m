From: "David S. Miller" <davem@davemloft.net>
Subject: Re: sendpage and high mem pages
Date: Thu, 20 Apr 2006 12:35:43 -0700 (PDT)
Message-ID: <20060420.123543.113480414.davem@davemloft.net>
References: <4447E102.5080203@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44235
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751127AbWDTTfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 15:35:53 -0400
To: michaelc@cs.wisc.edu
In-Reply-To: <4447E102.5080203@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Christie <michaelc@cs.wisc.edu>
Date: Thu, 20 Apr 2006 14:29:06 -0500

> I was wondering if it is ok to pass sendpage high mem pages. If a piece
> of code does this:
> 
> struct socket *sock;
> 
> sock->ops->sendpage(pg...)
> 
> and pg is a highmem page will the network layer do the right thing or
> should the caller check the page type and call sock_no_sendpage() for
> highmen? It looks like net/sunrpc/xprtsock.c does a check but
> drivers/scsi/iscsi_tcp.c and some others do not.

TCP and others handle this just fine, if something doesn't then it
needs to be fixed.  Any page in the page cache can be sent over this
interface.
