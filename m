From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] C/R: Basic support for network namespaces and
 devices (v5)
Date: Fri, 26 Feb 2010 04:08:55 -0800 (PST)
Message-ID: <20100226.040855.158431085.davem@davemloft.net>
References: <1267130595-23637-1-git-send-email-danms@us.ibm.com>
	<1267130595-23637-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, benjamin.thery@bull.net, den@openvz.org,
	ebiederm@xmission.com, netdev@vger.kernel.org
To: danms@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38665
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934992Ab0BZMIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:08:37 -0500
In-Reply-To: <1267130595-23637-3-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>
Date: Thu, 25 Feb 2010 12:43:11 -0800

> When checkpointing a task tree with network namespaces, we hook into
> do_checkpoint_ns() along with the others.  Any devices in a given namespace
> are checkpointed (including their peer, in the case of veth) sequentially.
> Each network device stores a list of protocol addresses, as well as other
> information, such as hardware address.
> 
> This patch supports veth pairs, as well as the loopback adapter.  The
> loopback support is there to make sure that any additional addresses and
> state (such as up/down) is copied to the loopback adapter that we are
> given in the new network namespace.
> 
> On restart, we instantiate new network namespaces and veth pairs as
> necessary.  Any device we encounter that isn't in a network namespace
> that was checkpointed as part of a task is left in the namespace of the
> restarting process.  This will be the case for a veth half that exists
> in the init netns to provide network access to a container.

To be safe you should probably use __be32 and store the IP
addresses in network byte order.

But other than that:

Acked-by: David S. Miller <davem@davemloft.net>
