From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/3] XFRM: RFC4303 compliant auditing
Date: Fri, 21 Dec 2007 08:51:22 -0500
Message-ID: <200712210851.22521.paul.moore@hp.com>
References: <20071220214200.12122.89628.stgit@flek.lan> <20071221.014310.155404661.davem@davemloft.net> <200712210827.24063.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	latten@austin.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:57518 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754949AbXLUNvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 08:51:54 -0500
In-Reply-To: <200712210827.24063.paul.moore@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 21 December 2007 8:27:23 am Paul Moore wrote:
> On Friday 21 December 2007 4:43:10 am David Miller wrote:
> > From: Paul Moore <paul.moore@hp.com>
> > Date: Thu, 20 Dec 2007 16:42:25 -0500
> >
> > > This patch adds a number of new IPsec audit events to meet the auditing
> > > requirements of RFC4303.  This includes audit hooks for the following
> > > events:
> > >
> > >  * Could not find a valid SA [sections 2.1, 3.4.2]
> > >    . xfrm_audit_state_notfound()
> > >    . xfrm_audit_state_notfound_simple()
> > >
> > >  * Sequence number overflow [section 3.3.3]
> > >    . xfrm_audit_state_replay_overflow()
> > >
> > >  * Replayed packet [section 3.4.3]
> > >    . xfrm_audit_state_replay()
> > >
> > >  * Integrity check failure [sections 3.4.4.1, 3.4.4.2]
> > >    . xfrm_audit_state_icvfail()
> > >
> > > While RFC4304 deals only with ESP most of the changes in this patch
> > > apply to IPsec in general, i.e. both AH and ESP.  The one case,
> > > integrity check failure, where ESP specific code had to be modified the
> > > same was done to the AH code for the sake of consistency.
> > >
> > > Signed-off-by: Paul Moore <paul.moore@hp.com>
> >
> > This doesn't apply at all to net-2.6.25, in particular
> > xfrm6_input_addr() doesn't even have a local variable
> > named "xfrm_vec_one" let alone the conditional where you're
> > adding the state notfound audit hook.
> >
> > Please respin this and the third patch, thanks.
>
> Sorry about that, I must have missed something (or probably just updated
> the wrong tree on accident).  I'll respin the patches and send them out
> today.

Ah, looks like I may not be crazy after all!  It looks like the XFRM patches 
from Masahide NAKAMURA were pulled into net-2.6.25 just before mine last 
night which caused my patches to conflict ...

-- 
paul moore
linux security @ hp
