From: dormando <dormando@rydia.net>
Subject: Re: Multitude of dst obsolescense race conditions
Date: Wed, 14 May 2014 11:01:08 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1405141059550.9591@dinf>
References: <alpine.DEB.2.02.1405140233210.16893@dtop> <1400074523.15916.117311749.3590532D@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400074523.15916.117311749.3590532D@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, May 14, 2014, at 2:57, dormando wrote:
> > Given a machine with frequently changing routes (ie; a router with an
> > active internet BGP table and multiple interfaces), there're at least
> > several places where obsolete dst's are handled improperly. If I pause
> > the
> > route changes, the crashes appear to stop. This first one has a crash
> > utility we've made, so I was able to more quickly find a patch and test
> > it. The others take time to reproduce.
> >
> > I'm testing against 3.10.39, but I think if these were fixed they'd be
> > backported to stable? I've also had recent 3.12's running that have
> > crashed in the same spots. Anyway correct me if I'm wrong...
>
> Just a hunch:
> You use macvlan? Could you somehow try without?
> Maybe... some ref overflow? (You could add some testing code in dst_hold
> with atomic_inc_return and WARN_ON).
>
> dst_release already contains such a check, so I am not sure at all if
> that could happen.
>
> Bye,
>
>   Hannes
>

We've seen the crashes with macvlan removed. Don't think I've explicitly
removed it recently or for the udp crash, but I'm sorta doubting that'd
make a difference.

and yeah, pretty weird right? it's like the RCU isn't working..
