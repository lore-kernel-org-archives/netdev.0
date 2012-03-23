From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Fri, 23 Mar 2012 07:05:56 +0100
Message-ID: <20120323060555.GB2311@netboy.at.omicron.at>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
 <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321160817.GB1941@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580DA6CC@ORSMSX105.amr.corp.intel.com>
 <20120322070900.GD2182@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB580DB022@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chetan loke <loke.chetan@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:61946 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab2CWGGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2012 02:06:07 -0400
Received: by wibhj6 with SMTP id hj6so1604790wib.1
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 23:06:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB580DB022@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 22, 2012 at 09:59:01PM +0000, Keller, Jacob E wrote:
> 
> This means that readers don't block at all, and as long as the
> readers don't conflict with each other, there is no contention or
> writer starvation. It is possible for readers to 'live' lock, due to
> a large number of write operations. However, the lock is designed
> for few-writers, many readers. Which is what we have.

The readers do conflict with each other simply by reading the
registers E1000_SYSTIML and E1000_SYSTIMH. The locking is needed in
order to make these two reads "atomic."

Thanks,
Richard
