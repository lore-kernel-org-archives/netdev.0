From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] SECMARK 1.0
Date: Mon, 8 May 2006 17:29:33 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605081719440.18947@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>  <445E288B.4040908@gentoo.org>
  <Pine.LNX.4.64.0605071323330.9423@d.namei> <1147110088.32719.56.camel@jackjack.columbia.tresys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joshua Brindle <method@gentoo.org>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:19949 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751097AbWEHV3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 17:29:35 -0400
To: Karl MacMillan <kmacmillan@tresys.com>
In-Reply-To: <1147110088.32719.56.camel@jackjack.columbia.tresys.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 8 May 2006, Karl MacMillan wrote:

> Something like CONNMARK seems preferable to me (perhaps even allowing
> type_transition rules to give the related packets a unique type). This
> makes the labeling reflect the real security property of the packets.

That's arguable.  The real security property afaict is that the packets 
are of some state (established or related to an existing connection).  It 
is implicit in the mechanism that they're tracked as part of an authorized 
connection.

> Yes, we are trusting the conntrack to mark the packets accurately, but
> it makes the policy match the intent. Otherwise it is not possible to
> reason about information flow using just the policy.

Why not?  You just state that all established and related packets reaching 
vsftpd are valid, and that no invalid packets can deliver data to the 
application.  You can play tricks and stick a label on a packet but that 
doesn't change what's actually happening or your ability to reason about 
it.  You assume conntrack works correctly (and if it doesn't, then 
labeling connections will break, too).

> Are there serious downsides to this approach?

Yes, it's an ugly hack which is not needed.

> > You can always not use conntrack and emulate the existing controls, as 
> > well.
> 
> Yes, but gaining connection tracking is a major advantage of this
> approach over the existing controls.

The point is to show that this scheme provides much stonger security 
assurrances, and that if you wished, you could easily rervert to stateless 
filtering and have the "correct" labels on the packets; which would be 
worse.



- James
-- 
James Morris
<jmorris@namei.org>
