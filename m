From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH] improved xfrm_audit_log() patch
Date: Wed, 22 Aug 2007 20:29:17 -0500
Message-ID: <1187832557.15699.687.camel@faith.austin.ibm.com>
References: <200708151616.l7FGGTk9001632@faith.austin.ibm.com>
	 <20070821.002405.88473654.davem@davemloft.net>
	 <20070822.125157.43008100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, sgrubb@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:38373 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711AbXHWBcM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 21:32:12 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7N1XWuq012617
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 21:33:32 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7N1WBSN552612
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 21:32:11 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7N1WAQ4004277
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 21:32:11 -0400
In-Reply-To: <20070822.125157.43008100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-08-22 at 12:51 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 21 Aug 2007 00:24:05 -0700 (PDT)
> 
> > Looks good, applied to net-2.6.24, thanks Joy.
> 
> Something is still buggered up in this patch, you can't add this local
> "audit_info" variable unconditionally to these functions, and
> alternatively you also can't add a bunch of ifdefs to xfrm_user.c to
> cover it up either.
> 
I wonder if I am subconsciously trying to break a record or 
something! My apologies as time is valuable. 

I mean to get this right. My rationale for using audit_info was to
reduce amount of arguments to xfrm_audit_log(). However, I now like
it better when I just called xfrm_audit_log(NETLINK_CB(skb).loginuid,
NETLINK_CB(skb).sid, ...). User determines where/how to get loginuid and
secid and nothing happens when AUDIT not configured. But would make
xfrm_audit_log() have 7 arguments instead of 6.

My alternative is to remove xfrm_get_auditinfo() out of the 
#ifdef CONFIG_AUDITSYSCALL and always fill in audit_info
regardless if AUDIT is configured or not. Less calls to
xfrm_audit_log() but perhaps unnecessary info when AUDIT 
not configured.

Would first solution be acceptable?

Joy   


