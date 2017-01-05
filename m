From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: SIOCSIWFREQ while in NL80211_IFTYPE_STATION
Date: Thu, 05 Jan 2017 15:06:44 +0100
Message-ID: <1483625204.4394.23.camel@sipsolutions.net>
References: <685811c3-6247-77fd-8c70-617951886451@linaro.org>
         <1483616301.4394.6.camel@sipsolutions.net>
         <92e60cb2-8bb4-df03-3434-4a055f575df0@linaro.org>
         (sfid-20170105_142703_879207_374EBEEC)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>
To: Jorge Ramirez <jorge.ramirez-ortiz@linaro.org>,
        netdev@vger.kernel.org, Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50220 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S969276AbdAEOGr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 09:06:47 -0500
In-Reply-To: <92e60cb2-8bb4-df03-3434-4a055f575df0@linaro.org> (sfid-20170105_142703_879207_374EBEEC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I am not sure it matters - if I understood your reply, there is no
> valid use case to change the frequency in that mode (and all that
> code should be removed); 

All of wext *is* being removed - slowly :)
It's not longer default in the kernel configuration now.

IIRC, there actually was a valid use case here - to set the frequency
before you set the SSID - to be able to force a connection on that
channel with wext.

> it seems to me that it is also your view that userspace (iwconfig)
> should be fixed accordingly to not call the extensions?

iwconfig should just be deleted and iw be used :-)

> I am just trying to understand how the current code is supposed to
> work  by exercising widely available user-space tools while debugging
> the kernel.

Heh, ok.

> Actually the frequency gets programmed without errors when reverting 
> your commit http://tinyurl.com/ho4urp8 (which comes as a surprise as
> well).

Well, it's not my commit, but that makes sense. I suppose we should
treat this as a regression, but reverting that doesn't seem like the
right fix. Actually, I'm not convinced we should do monitor channel
change anyway when you set the frequency with wext, so we can probably
just remove that call there - want to send a patch to that effect?

johannes
