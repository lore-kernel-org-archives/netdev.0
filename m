From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] improved xfrm_audit_log() patch
Date: Tue, 21 Aug 2007 00:24:05 -0700 (PDT)
Message-ID: <20070821.002405.88473654.davem@davemloft.net>
References: <200708151616.l7FGGTk9001632@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, sgrubb@redhat.com
To: latten@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57150
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751099AbXHUHYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 03:24:06 -0400
In-Reply-To: <200708151616.l7FGGTk9001632@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joy Latten <latten@austin.ibm.com>
Date: Wed, 15 Aug 2007 11:16:29 -0500

> On Tue, 2007-08-07 at 18:32 -0700, David Miller wrote:
> >From: Joy Latten <latten@austin.ibm.com>
> >Date: Thu, 2 Aug 2007 15:56:47 -0500
> >
> >> @@ -426,10 +426,15 @@ struct xfrm_audit
> >>  };
> >>  
> >>  #ifdef CONFIG_AUDITSYSCALL
> >> -extern void xfrm_audit_log(uid_t auid, u32 secid, int type, int result,
> >> -		    struct xfrm_policy *xp, struct xfrm_state *x);
> >> +extern void xfrm_audit_log(struct xfrm_audit audit_info, int result,
> >> +			   __be32 flowid, struct xfrm_policy *xp, 
> >> +			   struct xfrm_state *x, char *buf);
> >
> >Passing audit_info as an aggregate argument puts them into
> >previous argument registers, or if they are not enough it
> >goes either partially of wholly onto the stack, depending
> >upon architecture.
> >
> >In fact you've made the argument register usage worse than
> >in your previous revision. :-/
> >
> >Perhaps you meant to pass "struct xfrm_audit *" instead?
> 
> Revised patch to pass pointer to struct xfrm_audit.
> Sorry, I missed that.
> 
> Signed-off-by: Joy Latten <latten@austin.ibm.com>

Looks good, applied to net-2.6.24, thanks Joy.

