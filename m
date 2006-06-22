From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH 01/06] MLSXFRM: Granular IPSec associations for use in
 MLS environments
Date: Thu, 22 Jun 2006 19:53:11 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606221918120.24497@d.namei>
References: <36282A1733C57546BE392885C06185920132419A@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:64688 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161462AbWFVXxO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 19:53:14 -0400
To: Venkat Yekkirala <vyekkirala@TrustedCS.com>
In-Reply-To: <36282A1733C57546BE392885C06185920132419A@chaos.tcs.tcs-sec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Jun 2006, Venkat Yekkirala wrote:

> > Can you clarify whether, with this patch, Linux will then have a 
> > complete labeled network implementation in terms of both LSPP 
> > compliance and common user requirements?
> 
> I can't comment on the LSPP compliance issue since the specific/proprietary
> security target being used might really decide what's needed.
> 
> As for common user requirements, at least as I understand them, I would
> look for the following in addition to this patch:
> 
> - Auto-labelling of child sockets for TCP (I am planning on sending a
> separate
>   patch out in the next few days).
> - Using the label from the incoming packet while sending timewait
> acknowledgements
>   and other packets sent on behalf of kernel sockets.

I think we'd want to have these as part of this MLS enhancement patchset.  

As-is, it's not functional in a production quality sense, in that, simple 
common actions such as a user pressing ctrl-c in an ftp client can cause 
TCP to break, because packets not owned any more by a process will be 
labeled differently.

Features added to the upstream kernel need to be 'complete' in that they 
provide some minimally functional set of features, and meet a clear user 
requirement.  This code seems to be only partially complete, and it's not 
clear to me (and likely other network maintainers) what a complete 
implementation should look like.

What we need is a design rationale, some kind of detailed discussion of 
what the user requirements are and what the plan is for implementing 
features to meet these requirements.

Then, we can trace patchsets back to the requirements and understand where 
each patchset gets us in terms of orderly progression toward 
specific goals.

> - sid prioritization among the current mix of secmark, ipsec, and the
> upcoming netlabel
> - Replacing secmark on output with an access check in postrouting.

This area in general, the interaction between local packet labeling and on 
the wire labeling, needs some solid analysis and discussion on netdev, so 
that the correct solution can be implemented.

It should not be an afterthought.

> - localhost traffic handling with regard to labelling.

Again, this is an important area, but currently seems like an 
afterthought.

And what about userland APIs relating to MLS labeling?  Does the kernel 
currently provide everything you think you need in this respect?

What about polyinstantiated ports?

What about interaction with namespaces and containers?


> > > Outstanding items/issues: - Timewait acknowledgements and such are 
> > > generated in the current/upstream implementation using a NULL socket
> > resulting in the 
> > > any_socket sid (SYSTEM_HIGH) to be used. This problem is 
> > not addressed 
> > > by this patch set.
> > 
> > This needs to be resolved, along with labeling for all kernel owned 
> > socket/tw objects.
> 
> Resolved these should be, but given the fact that this patch doesn't 
> introduce this problem in the first place, and given the value it adds 
> to the xfrm stuff, my hope would be for this patch to be treated 
> separately. I am hoping for 2.6.18 if possible.

The problem is that not all of the packets are being labeled the way you 
want them to be.  It's a partial solution which I can't imagine being 
useful to anyone in a practical scenario.

Upstream developers are not experts in MLS, yet need to be able to make 
informed decisions on whether patches being submitted are appropriate: 
better documentation is required.

The original SELinux submissions presented a significant shift in thinking 
on security, but they were supported by extensive documentation including 
the user requirement for MAC and detailed design rationale.  This made it 
possible for kernel maintainers to understand what was being submitted.

Similar is required for these MLS enhancements to networking, including 
some broader thinking about general architectural directions (e.g. how 
this fits in with namespaces, as mentioned above, and also possibly, 
whether APIs and other components are suitable also for legacy MLS 
labeling schemes, at least two of which are being worked on).

There's also the question of ongoing maintenance in the mainline kernel.  
Unfortunately, there's been an increasing trend recently for companies to 
drop code over the wall.  For example, once they get it to some basic 
level of completeness, and the initial patches are merged, their 
developers are reassigned to other projects and the upstream maintainers 
are left with code that's not yet up to Linux kernel quality and also 
something they may not understand very well.  So, we need to know whether 
TCS or anyone else with expert knowledge of MLS will be helping months or 
years down the track, once this code has been merged.


- James
-- 
James Morris
<jmorris@namei.org>
