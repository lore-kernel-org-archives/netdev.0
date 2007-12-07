From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] XFRM: RFC4303 compliant auditing
Date: Fri, 7 Dec 2007 16:06:37 -0500
Message-ID: <200712071606.38108.paul.moore@hp.com>
References: <20071207195752.31819.44606.stgit@flek.americas.hpqcorp.net> <1197060751.3183.22.camel@dhcp231-215.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:2575 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbXLGVGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 16:06:43 -0500
In-Reply-To: <1197060751.3183.22.camel@dhcp231-215.rdu.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 December 2007 3:52:31 pm Eric Paris wrote:
> On Fri, 2007-12-07 at 14:57 -0500, Paul Moore wrote:
> > NOTE: This really is an RFC patch, it compiles and boots but that is
> > pretty much all I can promise at this point.  I'm posting this patch to
> > gather feedback from the audit crowd about the continued overloading of
> > the AUDIT_MAC_IPSEC_EVENT message type - continue to use it or create a
> > new audit message type?  Of course any other comments people may have are
> > always welcome.
>
> I'm all for continuing to use it, but I feel like the op= strings should
> probably all get collected up in one place to ease maintenance in the
> future, might not matter but it's nice to be able to look only on place
> in the code to find all of the possible op=

Agreed.  I punted on doing anything here for two main reasons:

1. It makes sense to do this in the xfrm_audit_start() function which I 
couldn't use here without some overhaul ...
2. ... I didn't want to overhaul anything if I was going to end up using 
separate message types.

If we decide to go with a single audit message type (kinda sounds like it) 
I'll fix this up in the next version.

> The one advantage to multiple messages is the ability to exclude and not
> audit certain things.  How often will these extra messages actually pop
> out of a system?  Enough that people would likely still care about some
> of them but decide they don't want others?  I don't know this stuff, so
> tell me how often would any of these show up?

Bingo, this is the whole reason why I was wondering about a different message 
type.  Currently only SAD and SPD changes are audited and only because they 
effect the security labels that are assigned to packets as they are 
imported/exported out of the system (look at the LSPP requirements for 
auditing the import and export of data).  These new audit messages apply to 
individual packets and/or a particular SA and have nothing to do with 
security labels, rather they indicate error conditions found during normal 
IPsec processing.  It would be difficult to think of all of the particular 
cases where these error conditions but in general I would say that these 
audit messages should not be common.

The only reason for creating a separate audit message type for these packet/SA 
messages would be to meet a RFC requirement that states that the 
implementation MUST allow the administrator to enable and disable ESP 
auditing.  Now, we can probably say we fulfill that requirement regardless, 
but more message types allow us greater granularity and flexibility ...

-- 
paul moore
linux security @ hp
