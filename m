From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] SECMARK 1.1
Date: Mon, 15 May 2006 00:24:00 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605150004590.645@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
 <Pine.LNX.4.64.0605140133560.5506@d.namei> <446778F0.6000705@trash.net>
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
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:16869 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751403AbWEOEYD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 00:24:03 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <446778F0.6000705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 14 May 2006, Patrick McHardy wrote:

> James Morris wrote:
> > @@ -135,6 +175,9 @@ static int __init xt_secmark_init(void)
> >  {
> >  	int err;
> >  
> > +	if (tracking_enabled())
> > +		need_conntrack();
> > +
> 
> This will load the conntrack modules even if the track flag is not set.

I guess need_conntrack() could be moved to checkentry() and only called 
if the track flag is set.


> Wouldn't it be better to put everything related to connection marking
> in the CONNSECMARK target?

It's more efficient this way, and simpler to manage.  

Currently, after security marking, the chain should normally terminate 
with a -j ACCEPT.  Requiring the use of CONNSECMARK to label connections 
means inserting another rule before terminating the chain.

Also, security marking for connections only occurs in the context of 
copying the security mark from packets, so there's no reason to build a 
general feature to do this into CONNSECMARK.

Another possibility would be to get rid of CONNSECMARK completely and have 
SECMARK copy security marks from connections to packets via the use of a 
different flag (perhaps change --track into --save-state and then have 
--restore-state, or similar).


- James
-- 
James Morris
<jmorris@namei.org>
