From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Fri, 24 Mar 2017 12:56:19 -0300
Message-ID: <20170324155619.GC23552@localhost.localdomain>
References: <1486128246.21871.83.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203135355.GA3413@localhost.localdomain>
 <1486131366.21871.87.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203142828.GB3413@localhost.localdomain>
 <1486133253.21871.89.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170206211226.GC3413@localhost.localdomain>
 <20170319121417.GA293@x4>
 <1489951226.16816.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170320192714.GB23552@localhost.localdomain>
 <1490190462.16816.144.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40780 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934511AbdCXP4X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 11:56:23 -0400
Content-Disposition: inline
In-Reply-To: <1490190462.16816.144.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 22, 2017 at 06:47:42AM -0700, Eric Dumazet wrote:
> On Mon, 2017-03-20 at 16:27 -0300, Marcelo Ricardo Leitner wrote:
> >  This warning is a hint, and can not assume senders are not dumb.
> > 
> > Agreed. But we can make it consider such cases. What about the following
> > patch? (untested)
> > 
> > I think we can directly account for the size of the timestamps in there,
> > as that won't make a difference to congestion control in case it's
> > wrong, and also validate against MTU if we have it. I didn't subtract
> > the headers from MTU on purpose, as dealing with ipv4/ipv6 there is
> > not worth for the same reason.
> > 
> > This should silent this false-positive.
> 
> 
> Note that the problem could have its origin on a middle box,
> not on the host terminating the TCP flow.
> 
> So we can try hard, but we can't eliminate false positives.

Agreed both.

> 
> Maybe replace the 12 by MAX_TCP_OPTION_SPACE ?

Yes, can be. Thanks.

  Marcelo
