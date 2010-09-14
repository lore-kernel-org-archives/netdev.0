From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 18492] New: kernel softirq warning on boot
Date: Tue, 14 Sep 2010 13:57:30 -0700
Message-ID: <20100914135730.8af6bc76.akpm@linux-foundation.org>
References: <bug-18492-10286@https.bugzilla.kernel.org/>
	<20100914120738.6a658f69.akpm@linux-foundation.org>
	<AANLkTinE50xFx9nShGBeOf483G2FhogO-BCj=dfHBZS7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Michal Suchanek <hramrach@centrum.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37943 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752294Ab0INU6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 16:58:34 -0400
In-Reply-To: <AANLkTinE50xFx9nShGBeOf483G2FhogO-BCj=dfHBZS7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Sep 2010 22:45:19 +0200
Michal Suchanek <hramrach@centrum.cz> wrote:

> > rcu_read_unlock_bh() in netpoll_rx(), added by "netpoll: Fix RCU
> > usage".
> 
> Do you mean de85d99eb7b595f6751550184b94c1e2f74a828b?

yup.

> I am not sure reverting just that would work, nor that the kernel
> around that point is in shape for trying on a system I would want to
> still use. It's way back in history for a kernel which is just to be
> released.

No, we wouldn't want to revert it - it fixes stuff.

It could be that we just don't need the _bh locking, if local irqs are
reliably disabled.  But I didn't really look.

