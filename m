From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: Re: tg3_close question
Date: Thu, 9 Nov 2006 19:29:26 +0100
Message-ID: <5cac192f0611091029k72f16e5dw7f9507c46c43e864@mail.gmail.com>
References: <5cac192f0611090922x7b6f8369of5bf294e9768800d@mail.gmail.com>
	 <1551EAE59135BE47B544934E30FC4FC093FCD0@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:4048 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1424191AbWKIS33 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 13:29:29 -0500
Received: by wr-out-0506.google.com with SMTP id i32so154386wra
        for <netdev@vger.kernel.org>; Thu, 09 Nov 2006 10:29:28 -0800 (PST)
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FCD0@NT-IRVA-0751.brcm.ad.broadcom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/9/06, Michael Chan <mchan@broadcom.com> wrote:
> Eric Lemoine wrote:
>
> > > On 11/9/06, Michael Chan <mchan@broadcom.com> wrote:
> > > > So it is not possible for tg3_poll() -> tg3_tx() to run any more
> > > > after tg3_close() is called.
> > >
> > > But, while tg3_close() starts executing, an interrupt may
> > > come in and
> > > schedule polling (set  __LINK_STATE_RX_SCHED). So tg3_poll() ->
> > > tg3_tx() may well occur.
> >
> > Actually I don't understand the purpose of having dev_close() wait for
> > __LINK_STATE_RX_SCHED to be cleared. An interrupt may arrive at any
> > time after it's cleared, and reset __LINK_STATE_RX_SCHED. Can someone
> > explain please?
> >
>
> If netif_running() is cleared, netif_rx_schedule() will not schedule
> the ->poll().  So even if tg3 gets an interrupt after close,
> tg3_poll() will not be scheduled.

Oh! I had missed the netif_running() check in netif_rx_schedule_prep().

Thanks Michael and Maxime for this clarification.

-- 
Eric
