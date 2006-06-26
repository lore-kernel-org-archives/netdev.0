From: Andrey Savochkin <saw@swsoft.com>
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Mon, 26 Jun 2006 19:27:51 +0400
Message-ID: <20060626192751.A989@castle.nmd.msu.ru>
References: <20060609210202.215291000@localhost.localdomain> <20060609210625.144158000@localhost.localdomain> <20060626134711.A28729@castle.nmd.msu.ru> <449FF5A0.2000403@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk, Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:40457 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1751230AbWFZP1x
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 11:27:53 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <449FF5A0.2000403@fr.ibm.com>; from "Daniel Lezcano" on Mon, Jun 26, 2006 at 04:56:32PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel,

On Mon, Jun 26, 2006 at 04:56:32PM +0200, Daniel Lezcano wrote:
> Andrey Savochkin wrote:
> > 
> > It's good that you kicked off network namespace discussion.
> > Although I wish you'd Cc'ed someone at OpenVZ so I could notice it earlier :).
> 
> devel@openvz.org ?

devel@openvz.org is fine

> 
> > When a device presents an skb to the protocol layer, it needs to know to which
> > namespace this skb belongs.
> > Otherwise you would never get rid of problems with bind: what to do if device
> > eth1 is visible in namespace1, namespace2, and root namespace, and each
> > namespace has a socket bound to 0.0.0.0:80?
> 
> Exact. But, the idea was to retrieve the namespace from the routes.

Then you lose the ability for each namespace to have its own routing entries.
Which implies that you'll have difficulties with devices that should exist
and be visible in one namespace only (like tunnels), as they require IP
addresses and route.

> 
> IMHO, I think there are roughly 2 network isolation implementation:
> 
> 	- make all network ressources private to the namespace
> 
> 	- keep a "flat" model where network ressources have a new identifier 
> which is the network namespace pointer. The idea is to move only some 
> network informations private to the namespace (eg port range, stats, ...)

Sorry, I don't get the second idea with only some information private to
namespace.

How do you want TCP_INC_STATS macro look?
In my concept, it would be something like
#define TCP_INC_STATS(field) SNMP_INC_STATS(current_net_ns->tcp_stat, field)
where tcp_stat is a TCP statistics array inside net_namespace.

Regards

Andrey
