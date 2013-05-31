From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next 02/12] tipc: Add "max_ports" configuration
 parameter
Date: Fri, 31 May 2013 10:25:38 +0200
Message-ID: <20130531082538.GB17727@eerihug-hybrid.ki.sw.ericsson.se>
References: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
 <1369942577-39563-3-git-send-email-paul.gortmaker@windriver.com>
 <20130530.154925.298481337221579707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:42371 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab3EaIkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 04:40:42 -0400
Content-Disposition: inline
In-Reply-To: <20130530.154925.298481337221579707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 03:49:25PM -0700, David Miller wrote:
> View compile time constants and module parameters as artificial
> limits, they are terrible and unnecessary.
> 
> There is no reason you cannot restructure this table so that you
> can dynamically size it at run time.

The TIPC ref table index is used directly as the port identity in the 
TIPC publications. When a socket is bound, this ID is published to all 
other nodes in the cluster.
If we where to allow the table to be changed dynamically, we would need
to change the port identities for already bound sockets/ports, withdraw
the old identity and publish the new one.
In the best case, this will lead to a temporary interruption for all
TIPC services until the new port ID's have been propagated out to the cluster.

> 
> Please reimplement it in that way.
> 

To allow dynamic resizing without the problem mentioned above, we would need 
to invent a new way of handling port ID's. Changing the direct indexing by 
port ID to a more generic method independant of the table size will cause 
an additional overhead in the data path, and I'm not sure it's worth the 
performance penalty to be able to change this limit dynamically. 

//E
