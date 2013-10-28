From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: use jiffies_64 value to
 calculate credit timeout
Date: Mon, 28 Oct 2013 11:30:43 +0000
Message-ID: <20131028113043.GA23262@zion.uk.xensource.com>
References: <1382872313-11675-1-git-send-email-wei.liu2@citrix.com>
 <526DCDB8.1080908@oracle.com>
 <526DD2D8.5030405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<david.vrabel@citrix.com>, <jbeulich@suse.com>,
	Jason Luan <jianhai.luan@oracle.com>
To: annie li <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23026 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756231Ab3J1Lao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 07:30:44 -0400
Content-Disposition: inline
In-Reply-To: <526DD2D8.5030405@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 28, 2013 at 10:58:32AM +0800, annie li wrote:
[...]
> >>      if (timer_pending(&vif->credit_timeout))
> >>          return true;
> >>        /* Passed the point where we can replenish credit? */
> >>-    if (time_after_eq(now, next_credit)) {
> >>-        vif->credit_timeout.expires = now;
> >>+    if (time_after_eq64(now, next_credit)) {
> >>+        vif->credit_timeout.expires = (unsigned long)now;
> >
> >updates credit_window_start as following,
> >vif->credit_window_start = (unsigned long)now;
> 
> both credit_window_start and credit_timeout.expires need to be
> updated here,
> 
> vif->credit_window_start = (unsigned long)now;
> vif->credit_timeout.expires = (unsigned long)now;
> 

IMHO we don't need to update .expires anymore -- we now track the window
with another variable.

Wei.
