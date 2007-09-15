From: David Miller <davem@davemloft.net>
Subject: Re: why does tcp_v[46]_conn_request not inc MIB stats
Date: Fri, 14 Sep 2007 20:11:52 -0700 (PDT)
Message-ID: <20070914.201152.35026256.davem@davemloft.net>
References: <46E5900A.3010009@hp.com>
	<1189461284.11066.10.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54479
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760191AbXIODMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 23:12:08 -0400
In-Reply-To: <1189461284.11066.10.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Mon, 10 Sep 2007 14:54:43 -0700

> looks like it is a hole in the stats. I think we should increment
> LISTENOVERFLOWS or LISTENDROPS in tcp_v[46]_conn_request too if the
> SYN is dropped.

No we should not.

This is limiting embryonic mini-socket creation.  The listen overflow
should only increment when the 3-way handshake completion is aborted
because the listening socket limit is exceeded, which is entirely
different from the embryonic limit.
