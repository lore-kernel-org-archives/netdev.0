From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Thu, 17 Oct 2013 15:06:11 +0100
Message-ID: <20131017140611.GM16371@zion.uk.xensource.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com>
 <525FBB4F02000078000FBB30@nat28.tlf.novell.com>
 <525FA79F.8060601@oracle.com>
 <525FAABE.5080806@citrix.com>
 <525FB9BC.9010608@oracle.com>
 <525FBC7F.9040800@citrix.com>
 <525FED42.4040608@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Jan Beulich <JBeulich@suse.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<annie.li@oracle.com>, <netdev@vger.kernel.org>
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:65366 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902Ab3JQOGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 10:06:12 -0400
Content-Disposition: inline
In-Reply-To: <525FED42.4040608@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 17, 2013 at 09:59:30PM +0800, jianhai luan wrote:
[...]
> >>>>If use time_after_eq64(), expire ,next_credit and other member will must
> >>>>be u64.
> >>>Yes, you'll need to store next_credit as a u64 in vif instead of
> >>>calculating it in tx_credit_exceeded from expires (which is only an
> >>>unsigned long).
> >>I know that.  Even we use u64, time_after_eq()  will also do wrong judge
> >>in theory (not in reality because need long long time).
> >If jiffies_64 has millisecond resolution that would be more than
> >500,000,000 years.
> 
> Yes, I agree the fact.
> >
> >>I think the two better fixed way is below:
> >>   - By time_before() to judge if now beyond MAX_ULONG/2
> >This is broken, so no.
> 
> Where is broken?  would you like to help me point it out.

I think David means you didn't actually fix the problem. Your solution is
merely a workaround.

> >
> >David
