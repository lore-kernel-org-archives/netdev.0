From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: Re: [PATCH 2/3 RFC] ath10k: wmi: match wait_for_completion_timeout
	return type
Date: Sat, 14 Mar 2015 09:59:38 +0100
Message-ID: <20150314085938.GA13323@opentech.at>
References: <1426175362-8640-1-git-send-email-hofrat@osadl.org> <CA+BoTQ=VYkOcKBjBuLsJcDjPNevTD2UFxVfB1uimRr=9uBO4Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Kalle Valo <kvalo@qca.qualcomm.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	"ath10k@lists.infradead.org" <ath10k@lists.infradead.org>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hofr.at ([212.69.189.236]:34625 "EHLO mail.hofr.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750925AbbCNI7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Mar 2015 04:59:40 -0400
Content-Disposition: inline
In-Reply-To: <CA+BoTQ=VYkOcKBjBuLsJcDjPNevTD2UFxVfB1uimRr=9uBO4Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Mar 2015, Michal Kazior wrote:

> On 12 March 2015 at 16:49, Nicholas Mc Guire <hofrat@osadl.org> wrote:
> > Return type of wait_for_completion_timeout is unsigned long not int.
> > An appropriately named unsigned long is added and the assignments fixed up.
> > Rather than returning 0 (timeout) or a more or less random remaining time
> > (completion success) this return 0 or 1 which also resolves the type of the
> > functions being int.
> >
> > Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
> > ---
> >
> > Checking the call-sites of ath10k_wmi_wait_for_unified_ready and
> > ath10k_wmi_wait_for_service_ready the positive return value (remaining
> > time in jiffies) is never passed up the call-chain nor used so it is
> > cleaner to treat this like a boolean success/fail only (actually the two
> > functions should probably be of type bool - but that does not seem to be
> > common practice in the ath10k code base)
> 
> It'd make sense to have these functions return 0 or -ETIMEDOUT. In
> that case both call sites would need to be adjusted to treat "< 0" or
> "!x" as an error (instead of the current "<= 0") condition and not set
> -ETIMEDOUT themselves.
>
looking at the call sites in ath10k_core_start more or less 
all other initialization calls will treate 0 as success and
!=0 as failure so this is the cleaner solution. as its all
now

status = call()
if(status)
 	error

patch just posted.

thx!
hofrat
