From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: tg3_close question
Date: Thu, 9 Nov 2006 18:22:45 +0100
Message-ID: <5cac192f0611090922x7b6f8369of5bf294e9768800d@mail.gmail.com>
References: <1551EAE59135BE47B544934E30FC4FC093FCCE@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <1551EAE59135BE47B544934E30FC4FC093FCCF@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <5cac192f0611090907v7b3f19m6916dcdba143996f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:15320 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S966044AbWKIRWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 12:22:49 -0500
Received: by ug-out-1314.google.com with SMTP id m3so283363ugc
        for <netdev@vger.kernel.org>; Thu, 09 Nov 2006 09:22:46 -0800 (PST)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <5cac192f0611090907v7b3f19m6916dcdba143996f@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/9/06, Eric Lemoine <eric.lemoine@gmail.com> wrote:
> On 11/9/06, Michael Chan <mchan@broadcom.com> wrote:
> > Michael Chan wrote:
> >
> > > Eric Lemoine wrote:
> > >
> > > > Instead of tg3_netif_stop() tg3_close() uses netif_stop_queue()
> > > > to stop xmit. This doesn't seem right to me. E.g. another CPU
> > > > in tg3_tx()
> > > > could do netif_wake_queue() just after tg3_close() did
> > > > netif_stop_queue(). Isn't a bug?
> > > >
> > >
> > > I think you're right.  It is more correct to call tg3_netif_stop().
> > >
> >
> > I take it back.  Before ->stop() is called, netif_running is cleared,
> > and it waits for __LINK_STATE_RX_SCHED to be cleared.  This means
> > that it will wait for the last ->poll() to finish.
>
> Correct.
>
> > So it is not possible for tg3_poll() -> tg3_tx() to run any more
> > after tg3_close() is called.
>
> But, while tg3_close() starts executing, an interrupt may come in and
> schedule polling (set  __LINK_STATE_RX_SCHED). So tg3_poll() ->
> tg3_tx() may well occur.

Actually I don't understand the purpose of having dev_close() wait for
__LINK_STATE_RX_SCHED to be cleared. An interrupt may arrive at any
time after it's cleared, and reset __LINK_STATE_RX_SCHED. Can someone
explain please?

Thanks,
-- 
Eric
