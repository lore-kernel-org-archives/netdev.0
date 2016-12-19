From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: "rfkill: Add rfkill-any LED trigger" causes deadlock
Date: Mon, 19 Dec 2016 09:56:12 +0100
Message-ID: <1482137772.31461.1.camel@sipsolutions.net>
References: <20161216163707.GA2629@gmail.com>
         <CACpa5=_chGuU3zVcVR3nkNySwz1cGAQTs39v+BjwcDNSvOqhTw@mail.gmail.com>
         (sfid-20161216_175504_934691_38742608)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?=D0=9C=D0=B8=D1=85=D0=B0=D0=B8=D0=BB_?=
         =?UTF-8?Q?=D0=9A=D1=80=D0=B8=D0=BD=D0=BA=D0=B8=D0=BD?=
        <krinkin.m.u@gmail.com>, kernel@kempniu.pl,
        linux-wireless@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:44010 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754680AbcLSI4T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 03:56:19 -0500
In-Reply-To: <CACpa5=_chGuU3zVcVR3nkNySwz1cGAQTs39v+BjwcDNSvOqhTw@mail.gmail.com> (sfid-20161216_175504_934691_38742608)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mike,

Thanks for the report. I'm sorry I missed this in review - obviously we
can't call something that acquires the mutex from rfkill_set_sw_state()
which clearly states, in the documentation:

 * This function can be called in any context, even from within rfkill
 * callbacks.

I've reverted the change (and the follow-up fix) now.

Michał, if you want to resubmit with this fixed, please also make sure
you don't reintroduce the unused label warning and have the appropriate
#ifdef that Arnd had later added for your change.

Thanks,
johannes
