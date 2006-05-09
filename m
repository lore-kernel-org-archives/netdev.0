From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] SECMARK 1.0
Date: Tue, 9 May 2006 12:40:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605091229190.25948@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>  <445E288B.4040908@gentoo.org>
 <Pine.LNX.4.64.0605071323330.9423@d.namei>  <1147110088.32719.56.camel@jackjack.columbia.tresys.com>
  <Pine.LNX.4.64.0605081719440.18947@d.namei> <1147181085.32719.105.camel@jackjack.columbia.tresys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joshua Brindle <method@gentoo.org>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:4549 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750732AbWEIQkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 12:40:19 -0400
To: Karl MacMillan <kmacmillan@tresys.com>
In-Reply-To: <1147181085.32719.105.camel@jackjack.columbia.tresys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 May 2006, Karl MacMillan wrote:

> those connection, but my concern is that connection could, through error
> or exploit, be passed to another domain that should not receive packets
> from that type of connection (see below).

Connection passing or inheritence should be subject to kernel MAC controls 
anyway (also see below).

> The use of a single related packet type loses the strong binding between
> the connection type (determined on connection) and domains, most likely
> because an established connection is passed to another process.
> 
> For example, for xinetd to work all of the xinetd children would be
> allowed to receive all related packets (i.e., tracked_packet_t). This
> means that if xinetd incorrectly passed, say, an ftp connection to
> telnet it would still be allowed to receive those packets because they
> would be of type tracked_packet_t. Labeling using something like
> connmark seems to solve this problem.

My understanding of xinetd is that it execs server applications, which 
inherit the connection fd.  In this case, flush_unauthorized_files() will 
ensure that the new domain is authorized to access the fd.

Stephen, can you confirm this?

> There may be other examples relating to enforcing data separation based 
> on other connection information, like the network interface, but I 
> haven't had a chance to work through those scenarios.

I'm not sure exactly what you mean here, but the idea of this scheme is 
that you can create new types to represent arbitrary combinations of 
security-relevant properites of a packet.

e.g. extif_ftp_packet_t for ftp packets over an external interface.

> Now you may be saying that it is not possible to determine with any
> assurance that a related packet is related to, for example, a connection
> that was initiated on the ftp port (and therefore given a different type
> - related_ftp_packet_t - fixing my xinetd example). If this is the case,
> your argument makes more sense to me.

This is not the case.  The problem is adding a secmark field to the 
connection tracking system, and then having to implement several rules for 
each labeling intent.  The conntrack is first labeled from the initial 
packet, then tracked packets are labeled from the conntrack label.  It's 
ugly.


- James
-- 
James Morris
<jmorris@namei.org>
