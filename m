From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/1] driver: veth: Refine the statistics
 codes of veth driver
Date: Thu, 03 Nov 2016 07:31:56 -0700
Message-ID: <1478183516.7065.440.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478178237-23020-1-git-send-email-fgao@ikuai8.com>
         <1478179858.7065.438.camel@edumazet-glaptop3.roam.corp.google.com>
         <CA+6hz4r9zkPp7-mG7b98ocPvjTiheSnEBMjffSkLXD1MM-aMtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        Evan Jones <ej@evanjones.ca>, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34162 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbcKCOcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 10:32:00 -0400
Received: by mail-pf0-f194.google.com with SMTP id y68so5048269pfb.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 07:32:00 -0700 (PDT)
In-Reply-To: <CA+6hz4r9zkPp7-mG7b98ocPvjTiheSnEBMjffSkLXD1MM-aMtg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-03 at 21:39 +0800, Gao Feng wrote:
> Hi Eric,
> 
> On Thu, Nov 3, 2016 at 9:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Thu, 2016-11-03 at 21:03 +0800, fgao@ikuai8.com wrote:
> >> From: Gao Feng <fgao@ikuai8.com>
> >>
> >> The dropped count of veth is located in struct veth_priv, but other
> >> statistics like packets and bytes are in another struct pcpu_vstats.
> >> Now keep these three counters in the same struct.
> >>
> >> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> >> ---
> >>  v2: Use right "peer" instead of "dev";
> >>  v1: Initial version
> >
> > May I ask : Why ?
> 
> Just because I think statistics should be in the same struct.

That is not a good reason then.

> 
> >
> > We did that because there was no point making per-cpu requirements
> > bigger, for a counter that is hardly ever updated.
> >
> > Do you have a real case where performance dropping packets in a driver
> > is needed ?
> 
> No, I haven't met the performance issue now.

OK then kill this patch.

> 
> >
> > At some point we will have to stop dumb percpu explosion, when we have
> > 128+ cores per host. Folding all these percpu counters is taking a lot
> > of time too.
> >
> >
> >
> Ok, I get it. It is designed specially to put the dropped counter as
> atomic counter, not percpu.
> But I have one question that when put the counters as percpu, and when not?

Because the regular fast path needs to be fast ?

Try to _use_ veth without these percpu stats and be prepared to be
shocked.
