From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] SECMARK 1.1
Date: Mon, 15 May 2006 01:57:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605150153590.1275@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
 <Pine.LNX.4.64.0605140133560.5506@d.namei> <446778F0.6000705@trash.net>
 <Pine.LNX.4.64.0605150004590.645@d.namei> <446811D3.5080905@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>,
	Karl MacMillan <kmacmillan@tresys.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Bleher <bleher@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:17571 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932272AbWEOF5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 01:57:13 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <446811D3.5080905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2006, Patrick McHardy wrote:

> >>This will load the conntrack modules even if the track flag is not set.
> > 
> > 
> > I guess need_conntrack() could be moved to checkentry() and only called 
> > if the track flag is set.
> 
> 
> That won't help, the function itself does nothing, its just a symbol
> dependency.

Not sure what you mean: it will cause ip_conntrack to be loaded, which 
is needed when you specify the track flag.

> > Another possibility would be to get rid of CONNSECMARK completely and have 
> > SECMARK copy security marks from connections to packets via the use of a 
> > different flag (perhaps change --track into --save-state and then have 
> > --restore-state, or similar).
> 
> 
> The reason why I'm asking is because my understanding is that SECMARK
> would also be useful without conntrack,

Yes.

>  but automatically pulling in the module leaves no option not to use 
> conntrack except not to compile this part in.

Conntrack will only be loaded if someone uses "SECMARK --track", which is 
exactly what is desired.   Without --track, conntrack will not be loaded 
by SECMARK.



- James
-- 
James Morris
<jmorris@namei.org>
