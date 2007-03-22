From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Thu, 22 Mar 2007 15:23:50 -0600
Message-ID: <1174598630.3085.285.camel@faith.austin.ibm.com>
References: <200703221835.l2MIZdDw007850@faith.austin.ibm.com>
	 <20070322.120139.74735307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org, jmorris@namei.org,
	vyekkirala@trustedcs.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57527 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161071AbXCVVkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 17:40:19 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2MLeFDw029508
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 17:40:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2MLeFXo253402
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 17:40:15 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2MLeFqq006121
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 17:40:15 -0400
In-Reply-To: <20070322.120139.74735307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-22 at 12:01 -0700, David Miller wrote:
> From: Joy Latten <latten@austin.ibm.com>
> Date: Thu, 22 Mar 2007 12:35:39 -0600
> 
> > Within selinux we check for authorization before deleting entries from
> > SAD and SPD. 
> > 
> > We are not checking for authorization when flushing the SPD and
> > the SAD. It was perhaps missed in original patch.
> > 
> > This patch adds security check when flushing entries from SAD and SPD.
> > 
> > Please let me know if this patch is ok.
> > It was built against linux-2.6.21-rc4-git5. I have also tested it.
> > 
> > Signed-off-by: Joy Latten<latten@austin.ibm.com>
> 
> I don't understand this and it does not sit well with me.
> 
> If we are flushing the policy database, we are flushing it
> regardless of what the security layer might or might not say.
> 
> I would look at this patch differently if there were some
> security level key being checked for a match here, which is
> an input key to the flush, but that is not what is happening
> here as the object is being looked at by itself.

Yes, I understand what you are saying.
I was concerned about having to check each entry
to flush database.

I did this patch because we check for authorization
when deleting single specified entries from the SAD/SPD. It
seem like a hole to me that we check for this, but that same
user/process can delete the entire database with no checks.

Unfortunately, each policy entry or SA can have a different security
label. And that is why I would have to check each entry's
security label before deleting. To see if the user/process has
authorization to delete an entry with that security label.

Including selinux list for suggestions.

Joy

