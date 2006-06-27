From: Andrey Savochkin <saw@swsoft.com>
Subject: Re: [patch 3/4] Network namespaces: IPv4 FIB/routing in namespaces
Date: Tue, 27 Jun 2006 13:25:32 +0400
Message-ID: <20060627132532.C13959@castle.nmd.msu.ru>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru> <449FF5AE.2040201@fr.ibm.com> <20060626200513.GB5330@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:59656 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S933361AbWF0JZg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 05:25:36 -0400
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060626200513.GB5330@MAIL.13thfloor.at>; from "Herbert Poetzl" on Mon, Jun 26, 2006 at 10:05:14PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2006 at 10:05:14PM +0200, Herbert Poetzl wrote:
> On Mon, Jun 26, 2006 at 04:56:46PM +0200, Daniel Lezcano wrote:
> > Andrey Savochkin wrote:
> > >Structures related to IPv4 rounting (FIB and routing cache)
> > >are made per-namespace.
> > 
> > How do you handle ICMP_REDIRECT ?
> 
> and btw. how do you handle the beloved 'ping'
> (i.e. ICMP_ECHO_REQUEST/REPLY for and from
> guests?

I don't need to do anything special.  They are just IP packets.
If packets are local in the current net namespace, they are delivered to
socket or handled by icmp_rcv.

Certainly, packet/raw sockets shouldn't see packets they aren't supposed to
see.  For raw sockets, it implies making socket lookup aware of namespaces,
exactly like for TCP or UDP.

	Andrey
