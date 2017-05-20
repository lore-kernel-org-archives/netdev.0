From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net-next v2] bridge: fix hello and hold timers
 starting/stopping
Date: Sat, 20 May 2017 15:47:48 +0800
Message-ID: <20170520074748.GB12974@leo.usersys.redhat.com>
References: <20170519173043.10201-1-cera@cera.cz>
 <20170520055720.GA12974@leo.usersys.redhat.com>
 <CA+Nub0aY6hjWeg8h2Qgx_c+yazh5WnA1u0D8bDtxChjWXsEHSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, sashok@cumulusnetworks.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org, Xin Long <lucien.xin@gmail.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: ivan.vecera@cera.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35054 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdETHsB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 May 2017 03:48:01 -0400
Received: by mail-pf0-f195.google.com with SMTP id u26so11797757pfd.2
        for <netdev@vger.kernel.org>; Sat, 20 May 2017 00:48:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CA+Nub0aY6hjWeg8h2Qgx_c+yazh5WnA1u0D8bDtxChjWXsEHSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 20, 2017 at 09:06:16AM +0200, Ivan Vecera wrote:
> 2017-05-20 7:57 GMT+02:00 Hangbin Liu <liuhangbin@gmail.com>:
> > On Fri, May 19, 2017 at 07:30:43PM +0200, Ivan Vecera wrote:
> >> Current bridge code incorrectly handles starting/stopping of hello and
> >> hold timers during STP enable/disable.
> >>
> >> 1. Timers are stopped in br_stp_start() during NO_STP->USER_STP
> >>    transition. The timers are already stopped in NO_STP state so
> >>    this is confusing no-op.
> >
> > Hi Ivan,
> >
> > Shouldn't we start hello timer in br_stp_start when NO_STP -> BR_KERNEL_STP ?
> 
> As Nikolay mentioned, this is fixed by
> https://patchwork.ozlabs.org/patch/764685/

Ah, sorry. My mistake. I only saw xin's patch and your v2 patch. So I mixed
them up and thought this is xin's V2 patch. That's why I wonder we didn't
start hello timer in br_stp_start...

Now I see your v1 patch with:

The patch is a follow-up for "bridge: start hello_timer when enabling
KERNEL_STP in br_stp_start" patch from Xin Long."

Sorry for mixed them up.
> 
> >>
> >> 2. During USER_STP->NO_STP transition the timers are started. This
> >>    does not make sense and is confusion because the timer should not be
> >>    active in NO_STP state.
> >
> > Yes, but what about BR_KERNEL_STP -> NO_STP in function br_stp_stop() ?
> 
> The timer is lazily stopped by itself in its handler... or not rearmed
> respectively.

Yes, with xin's patch this timer will stoped by itself.

Thanks
Hangbin
