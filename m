From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Wed, 22 Mar 2017 06:47:42 -0700
Message-ID: <1490190462.16816.144.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170203115457.GA5296@localhost.localdomain>
         <1486128246.21871.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170203135355.GA3413@localhost.localdomain>
         <1486131366.21871.87.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170203142828.GB3413@localhost.localdomain>
         <1486133253.21871.89.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170206211226.GC3413@localhost.localdomain> <20170319121417.GA293@x4>
         <1489951226.16816.5.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170320192714.GB23552@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
        netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33304 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759665AbdCVNrp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 09:47:45 -0400
Received: by mail-pf0-f193.google.com with SMTP id p189so21416037pfp.0
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 06:47:44 -0700 (PDT)
In-Reply-To: <20170320192714.GB23552@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-20 at 16:27 -0300, Marcelo Ricardo Leitner wrote:
>  This warning is a hint, and can not assume senders are not dumb.
> 
> Agreed. But we can make it consider such cases. What about the following
> patch? (untested)
> 
> I think we can directly account for the size of the timestamps in there,
> as that won't make a difference to congestion control in case it's
> wrong, and also validate against MTU if we have it. I didn't subtract
> the headers from MTU on purpose, as dealing with ipv4/ipv6 there is
> not worth for the same reason.
> 
> This should silent this false-positive.


Note that the problem could have its origin on a middle box,
not on the host terminating the TCP flow.

So we can try hard, but we can't eliminate false positives.

Maybe replace the 12 by MAX_TCP_OPTION_SPACE ?
