From: David Miller <davem@davemloft.net>
Subject: Re: Network Namespace status
Date: Sun, 16 Sep 2007 15:36:43 -0700 (PDT)
Message-ID: <20070916.153643.13760549.davem@davemloft.net>
References: <m18x7a5qif.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	htejun@gmail.com, gregkh@suse.de, akpm@linux-foundation.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:60134
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753074AbXIPWgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 18:36:52 -0400
In-Reply-To: <m18x7a5qif.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 13 Sep 2007 13:12:08 -0600

> The final blocker to having multiple useful instances of network
> namespaces is the loopback device.  We recognize the network namespace
> of incoming packets by looking at dev->nd_net.  Which means for
> packets to properly loopback within a network namespace we need a
> loopback device per network namespace.  There were some concerns
> expressed when we posted the cleanup part of the patches that allowed
> for multiple loopback devices a few weeks ago so resolving this one
> may be tricky.

There was a change posted recently to dynamically allocate the
loopback device.  I like that (sorry I don't have a reference
to the patch handy), and you can build on top of that to get
the namespace local loopback objects you want.

static struct net_device *loopback_dev(struct net_namespace *net)
{
	...
}

You get the idea.
