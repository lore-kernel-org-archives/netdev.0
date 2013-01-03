From: Barry Grussling <barry@grussling.com>
Subject: Re: [PATCH 2/4] DSA: Convert msleep calls to usleep_range calls
Date: Thu, 3 Jan 2013 14:33:15 -0800
Message-ID: <CABLseQ6h8+Vu+eMwhTwC44vFArL107bLrwY-sipgR89RxWbSBA@mail.gmail.com>
References: <1357178098-4057-1-git-send-email-barry@grussling.com>
	<1357178098-4057-3-git-send-email-barry@grussling.com>
	<1357244056.2685.7.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f45.google.com ([209.85.212.45]:46918 "EHLO
	mail-vb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941Ab3ACWdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 17:33:16 -0500
Received: by mail-vb0-f45.google.com with SMTP id p1so15797909vbi.4
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 14:33:15 -0800 (PST)
In-Reply-To: <1357244056.2685.7.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 3, 2013 at 12:14 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> I seriously doubt that it is worth the trouble to save wake-ups during
> the occasional hardware reset.  And using usleep_range() 1000 times is
> weird.  If the sleep duration can vary then the right thing to do is
> probably to calculate a deadline first (jiffies + HZ) and then sleep
> repeatedly until the deadline is in the past.  This also accounts for
> the fact that HZ may be < 1000...

I don't think the idea here is variable sleep time.  Its more just
giving hardware a little
bit of time to catch up with firmware.  I don't really care about
variable sleep times,
but checkpatch.pl says msleep of less than 20 ms is bad and may result in sleep
times of up to 20 ms for requests of shorter durations.

Should I use udelay instead?  What is the recommended method for sleeping 1 ms?

Thanks for your help.
