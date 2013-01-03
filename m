From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/4] DSA: Convert msleep calls to usleep_range calls
Date: Thu, 3 Jan 2013 20:14:16 +0000
Message-ID: <1357244056.2685.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <1357178098-4057-1-git-send-email-barry@grussling.com>
	 <1357178098-4057-3-git-send-email-barry@grussling.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Barry Grussling <barry@grussling.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35865 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430Ab3ACUOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 15:14:19 -0500
In-Reply-To: <1357178098-4057-3-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-02 at 17:54 -0800, Barry Grussling wrote:
> Convert DSA msleep calls to usleep_range calls as reported by
> checkpatch.pl.
> 
> Values of sleep duration were verified on Marvell hardware
> platform and appear to work.  Values chosen are not special
> and no strong "vetting" has gone into them other than verifying
> correct operation on available hardware.
[...]

I seriously doubt that it is worth the trouble to save wake-ups during
the occasional hardware reset.  And using usleep_range() 1000 times is
weird.  If the sleep duration can vary then the right thing to do is
probably to calculate a deadline first (jiffies + HZ) and then sleep
repeatedly until the deadline is in the past.  This also accounts for
the fact that HZ may be < 1000...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
