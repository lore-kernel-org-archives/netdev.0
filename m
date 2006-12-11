From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH] ieee80211softmac: Fix errors related to the work_struct
 changes
Date: Sun, 10 Dec 2006 22:24:27 -0600
Message-ID: <457CDD7B.8080207@lwfinger.net>
References: <20061210173908.GB29871@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Broadcom Linux <bcm43xx-dev@lists.berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:46720 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760665AbWLKEYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 23:24:39 -0500
To: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>, dsd@gentoo.org
In-Reply-To: <20061210173908.GB29871@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Kunitz wrote:
> The signature of work functions changed recently from a context
> pointer to the work structure pointer. This caused a problem in
> the ieee80211softmac code, because the ieee80211softmac_assox_work
> function has  been called directly with a parameter explicitly
> casted to (void*). This compiled correctly but resulted in a
> softlock, because mutex_lock was called with the wrong memory
> address. The patch fixes the problem. Another issue was a wrong
> call of the schedule_work function. Softmac works again and this
> fixes the problem I mentioned earlier in the zd1211rw rx tasklet
> patch. The patch is against Linus' tree (commit af1713e0).
> 
> Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>

Thanks Ulrich for this patch. I had spent the better part of 2 days bisecting Linus's git tree 
trying to isolate the problem that kept the system from booting when my bcm43xx card was installed.

I thought that when someone _BROKE_ an interface with this kind of change, it was their duty to fix 
_ALL_ parts of the system that uses this facility. At a minimum, shouldn't all maintainers get a 
heads up? I don't subscribe to LKML, but I peruse the summary and I certainly do not recall seeing a 
warning that this change was coming.

Larry
