From: Shaw Vrana <shaw@vranix.com>
Subject: Re: watchdog timeout panic in e1000 driver
Date: Mon, 30 Oct 2006 19:22:18 -0800
Message-ID: <20061031032218.GA7804@gmail.com>
References: <4538BFF2.2040207@cj.jp.nec.com> <4538F080.5020003@intel.com> <453DD678.4010606@cj.jp.nec.com> <453E3C0B.5030600@intel.com> <453F6983.6020307@cj.jp.nec.com> <453F7E1F.4020406@intel.com> <45408F7B.3050209@cj.jp.nec.com> <4540C765.4000800@intel.com> <4545E3A4.9090004@cj.jp.nec.com> <454636B0.1010004@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kenzo Iwami <k-iwami@cj.jp.nec.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:8023 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1161549AbWJaDWY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Oct 2006 22:22:24 -0500
Received: by ug-out-1314.google.com with SMTP id 32so1346342ugm
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 19:22:23 -0800 (PST)
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <454636B0.1010004@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 30, 2006 at 09:30:24AM -0800, Auke Kok wrote:
> >Even if the total lock time can be reduced, it's possible that interrupt
> >handler is executed while the interrupted code is still holding the 
> >semaphore.
> >I think your method only decrease the frequency of this problem.
> >Why does reducing the lock time solve this problem?
> 
> there are several problems here that need addressing. It's not acceptable 
> for our driver to wait up to 15 seconds, and we can (presumably) reduce it 
> to milliseconds, so that would help a lot. We should in no case at all hold 
> it for any period longer than (give or take) half a second, so working 
> towards that is a very good step in the right direction.
> 
> Adding the timer task back may also help, as we are no longer trying to 
> aqcuire the sw_fw_semaphore in interrupt context, but we removed it for a 
> reason, and I need to dig up what reason this exactly was before we can 
> revert it. Jesse might know, so I'll talk to him. But this will not fix the 
> fact that the semaphore is held for a long time :)


Timer tasks that reschedule themselves are a pain.  The watchdog timer task
had a couple of race conditions that were thought to be better fixed by
removing it all together.  Please, let's not go down that road again!

Check out what you have to say about it, Auke. ;)
http://www.spinics.net/lists/netdev/msg03656.html


Shaw
