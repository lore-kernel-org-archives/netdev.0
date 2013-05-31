From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 02/12] tipc: Add "max_ports" configuration parameter
Date: Fri, 31 May 2013 10:06:07 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B725D@saturn3.aculab.com>
References: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com> <1369942577-39563-3-git-send-email-paul.gortmaker@windriver.com> <20130530.154925.298481337221579707.davem@davemloft.net> <20130531082538.GB17727@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <paul.gortmaker@windriver.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>, <ying.xue@windriver.com>
To: "Erik Hugne" <erik.hugne@ericsson.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33747 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751489Ab3EaJGy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 05:06:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30584-08 for <netdev@vger.kernel.org>;
 Fri, 31 May 2013 10:06:48 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130531082538.GB17727@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > View compile time constants and module parameters as artificial
> > limits, they are terrible and unnecessary.
> >
> > There is no reason you cannot restructure this table so that you
> > can dynamically size it at run time.
> 
> The TIPC ref table index is used directly as the port identity in the
> TIPC publications. When a socket is bound, this ID is published to all
> other nodes in the cluster.
> If we where to allow the table to be changed dynamically, we would need
> to change the port identities for already bound sockets/ports, withdraw
> the old identity and publish the new one.
> In the best case, this will lead to a temporary interruption for all
> TIPC services until the new port ID's have been propagated out to the cluster.

Eh?
Doubling the size of the array doesn't require that the old index
be invalidated. At most it requires an rcu before the old index
array is discarded.

If you use the low bits of the port indentity (32bits ?) as the
table index and the higher bits as a seq value to identify stale
references then you need to distribute the old entries into the
correct places in the new table.
This isn't hard and there could be generic 'reference allocator'
that would do this for you.

	David
