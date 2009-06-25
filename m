From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.30-git21] Network Namespace test failure
Date: Thu, 25 Jun 2009 02:49:14 -0700 (PDT)
Message-ID: <20090625.024914.114440252.davem@davemloft.net>
References: <4A42391A.4040802@in.ibm.com>
	<20090625031449.GA26767@us.ibm.com>
	<20090625033847.GA27181@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sachinp@in.ibm.com, netdev@vger.kernel.org,
	serue@linux.vnet.ibm.com, matthltc@us.ibm.com,
	shemminger@vyatta.com
To: serue@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37727
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312AbZFYJtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 05:49:09 -0400
In-Reply-To: <20090625033847.GA27181@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Serge E. Hallyn" <serue@us.ibm.com>
Date: Wed, 24 Jun 2009 22:38:47 -0500

>>From 7193023ad09dbc4b57909c0204c19ed93472cd9e Mon Sep 17 00:00:00 2001
> From: root <root@elm3b203.beaverton.ibm.com>
> Date: Wed, 24 Jun 2009 20:26:17 -0700
> Subject: [PATCH 1/1] veth: don't free priv->status until dev->destructor
> 
> Since commit ae0e8e82205c903978a79ebf5e31c670b61fa5b4, priv->status
> has been freed at veth_close().  But that causes a NULL deref at
> veth_xmit.  This patch moves priv->status free back to the device
> destructor.
> 
> Signed-off-by: Serge Hallyn <serue@us.ibm.com>

I think ae0e8e82205c903978a79ebf5e31c670b61fa5b4 is worse than
the problem it's trying to cure.  It introduces two regressions:

1) This OOPS we are discussing.

2) statistics are not "remembered" across ifdown/ifup and that
   disagrees with how every other network device works

I'm going to revert that change, and the dev->destructor pointing
to module code problem will need to be fixed in another way.

Thanks.
