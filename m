From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next 02/12] tipc: Add "max_ports" configuration
 parameter
Date: Fri, 31 May 2013 10:34:55 +0200
Message-ID: <20130531083455.GA7568@eerihug-hybrid.ki.sw.ericsson.se>
References: <1369942577-39563-3-git-send-email-paul.gortmaker@windriver.com>
 <20130530.154925.298481337221579707.davem@davemloft.net>
 <20130531082538.GB17727@eerihug-hybrid.ki.sw.ericsson.se>
 <20130531.012922.204204156468438634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:61792 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab3EaIe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 04:34:57 -0400
Content-Disposition: inline
In-Reply-To: <20130531.012922.204204156468438634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 31, 2013 at 01:29:22AM -0700, David Miller wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> Date: Fri, 31 May 2013 10:25:38 +0200
> 
> > On Thu, May 30, 2013 at 03:49:25PM -0700, David Miller wrote:
> >> View compile time constants and module parameters as artificial
> >> limits, they are terrible and unnecessary.
> >> 
> >> There is no reason you cannot restructure this table so that you
> >> can dynamically size it at run time.
> > 
> > The TIPC ref table index is used directly as the port identity in the 
> > TIPC publications. When a socket is bound, this ID is published to all 
> > other nodes in the cluster.
> > If we where to allow the table to be changed dynamically, we would need
> > to change the port identities for already bound sockets/ports, withdraw
> > the old identity and publish the new one.
> 
> No you do not, simply grow the table just like we dynamically grow
> hash tables in response to network/socket activity elsewhere in the
> kernel.  You'll only allocate new indexes from the newly allocated
> area, the existing indexes will remain the same.

And if someone tries to reduce the table size?
Should we simply disallow that?

//E
