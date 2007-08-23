From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH] improved xfrm_audit_log() patch
Date: Thu, 23 Aug 2007 12:15:10 -0500
Message-ID: <1187889310.15699.735.camel@faith.austin.ibm.com>
References: <20070821.002405.88473654.davem@davemloft.net>
	 <20070822.125157.43008100.davem@davemloft.net>
	 <1187832557.15699.687.camel@faith.austin.ibm.com>
	 <20070822.200502.35874480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, sgrubb@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:49463 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840AbXHWRSI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 13:18:08 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7NHI6M7011193
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 13:18:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7NHI6El549854
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 13:18:06 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7NHI51d028324
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 13:18:05 -0400
In-Reply-To: <20070822.200502.35874480.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-08-22 at 20:05 -0700, David Miller wrote:
> I would suggest, at this point, to make purpose built situation
> specific interfaces that pass specific objects (the ones being
> operated upon) to the audit layer.
> 
> Let the audit layer pick out the bits it actually wants in the
> format it likes.
> 
> For example, if we're creating a template, pass the policy and
> the templace to the audit layer via a function called:
> 
> xfrm_audit_template_add()
> 
> or something like that.  That function only needs two arguments.
> 
> All of these call sites will rarely need more than 2 or 3 arguments in
> any given situation, and the on-stack audit thing will be gone too.
> 
> This is the suggestion I made to you over a month ago, but you choose
> to do the on-stack thing.
> 
I misunderstood. My bad.

For clarification, I plan on removing xfrm_audit_log() and replacing it
with more specific ipsec audit interfaces. 

For example, when auditing the addition of a policy, either
xfrm_user_audit_policy_add(xp, result, skb) or
pfkey_audit_policy_add(xp, result) will get called. 
I need two because xfrm_user gets loginuid/secid from netlink/skb
and pfkey gets it from audit_get_loginuid(). 
Each will setup and format audit buffer according
to what they want.

Also, for deleting, there will be pfkey_audit_policy_delete(xp, result)
and xfrm_user_audit_policy_delete(xp, result, skb).

> You must make this cost absolutely nothing when it is either
> not configured, and have next to no cost when not enabled at
> run time.  And it is very doable.

The new ipsec audit functions can be ifdef'd with CONFIG_AUDITSYSCALL
just as xfrm_audit_log() was so that there is no cost when 
audit is not configured. 

Let me know if this is better.

Regards,
Joy
