From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Thu, 22 Mar 2007 17:50:51 -0600
Message-ID: <1174607451.3085.290.camel@faith.austin.ibm.com>
References: <200703221835.l2MIZdDw007850@faith.austin.ibm.com>
	 <20070322.120139.74735307.davem@davemloft.net>
	 <1174598630.3085.285.camel@faith.austin.ibm.com>
	 <Line.LNX.4.64.0703221943110.24461@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, selinux@tycho.nsa.gov,
	netdev@vger.kernel.org, vyekkirala@trustedcs.com
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:42656 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbXCWAHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 20:07:15 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2N07EEC026877
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 20:07:14 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2N07EG2066672
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 18:07:14 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2N07DaO031715
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 18:07:14 -0600
In-Reply-To: <Line.LNX.4.64.0703221943110.24461@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-22 at 19:49 -0400, James Morris wrote:
> On Thu, 22 Mar 2007, Joy Latten wrote:
> 
> > > I would look at this patch differently if there were some
> > > security level key being checked for a match here, which is
> > > an input key to the flush, but that is not what is happening
> > > here as the object is being looked at by itself.
> > 
> > Yes, I understand what you are saying.
> > I was concerned about having to check each entry
> > to flush database.
> > 
> > I did this patch because we check for authorization
> > when deleting single specified entries from the SAD/SPD. It
> > seem like a hole to me that we check for this, but that same
> > user/process can delete the entire database with no checks.
> 
> Indeed.  Removing an entry is modifying MAC policy, which requires 
> appropriate authorization.
> 
> The security label is encapsulated with the object, which is why it's 
> passed to the security layer.
> 
> Perhaps a better semantic would be to fail the entire flush operation if 
> one of the security checks failed.  e.g. loop through for permissions 
> first, then if all ok, loop through for deletion.
> 
Ok, will code this up and test it if there are no objections.

Joy
