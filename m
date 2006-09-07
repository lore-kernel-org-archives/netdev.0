From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] ucode debug status via sysfs for wireless-2.6
Date: Thu, 07 Sep 2006 16:05:22 -0500
Message-ID: <45008992.2080601@lwfinger.net>
References: <20060904205340.GB3726@tuba> <200609071033.52258.mb@bu3sch.de> <45001CCA.1000304@lwfinger.net> <200609072248.39588.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Martin Langer <martin-langer@gmx.de>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org, John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:14250 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1422660AbWIGVFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 17:05:39 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609072248.39588.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> 
> In general, no.
> But, for some sysfs attrs it is sufficient to only take
> the mutex, because:
> * We don't access hardware.
> * We don't modify this data in a spinlock-only critical section.
> 
> Yes, I know that having two locks does not really fit the
> "lock data, not code" model. But it's well defined in bcm43xx,
> so I think we can live with it. (and we must live with it,
> if we want to have preemptible periodic work. And we _want_).
> It's defined by the following rules:
> 
> 1) Always take both, mutex and lock.
> 2) There are only two places where we can't take the
>    mutex, but only the spinlock. IRQ and TX paths.
> 
> (Yes, I know that there are still exceptions to 2.
> At least in dscape. The softmac port should be OK.
> These are bugs, I am aware of them and will fix it)
> 
> So these two rules lead to the following rule:
> 
> * Code where we only take the mutex can race against the
> TX and IRQ paths.
> Now we come back to the sysfs problem above. If the data, we
> access in this sysfs code, is not touched in either TX or IRQ path
> we don't need to take the spinlock. Yes, it's a little bit black
> magic. So if you aren't sure, always take both locks.

Thanks for the clarification.

Larry
