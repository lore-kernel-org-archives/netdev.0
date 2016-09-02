From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/2] sctp: not copying duplicate addrs to the
 assoc's bind address list
Date: Fri, 2 Sep 2016 14:25:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00F04FB@AcuExch.aculab.com>
References: <cover.1471605833.git.lucien.xin@gmail.com>
 <130956b1e880eab780162a795fde156d61d4de0f.1471605833.git.lucien.xin@gmail.com>
 <20160819175007.GB3578@hmsreliant.think-freely.org>
 <CADvbK_do3kQSotq7-PbvoCBBSwOBBdZtx=rR+Q2XX3_bhV4_0w@mail.gmail.com>
 <20160822142538.GA10323@hmsreliant.think-freely.org>
 <20160824112338.GB11144@localhost.localdomain>
 <CADvbK_dJbaze7qMsDp-7x0xANsXZX=JfYBNhKOo=2VgbM_ywZg@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB00EF186@AcuExch.aculab.com>
 <20160902134657.GB11159@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Xin Long' <lucien.xin@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        davem <davem@davemloft.net>, Vlad Yasevich <vyasevich@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.191]:51752 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932182AbcIBO2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 10:28:12 -0400
In-Reply-To: <20160902134657.GB11159@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner
> Sent: 02 September 2016 14:47
...
> > Consider the following network:
> >
> >     ----+---------------+----------------------+---------
> >         |               |                      |
> >      x.x.1.1         x.x.1.2                y.y.1.2
> >     10.1.1.1        10.1.1.2               10.1.1.2
> >         |               |                      |
> >     ----+---------------+                      +---------
...
> > I'm not at sure whether it is possible to setup listener(s) on x.x.1.1
> > that can accept connections from both x.x.1.2 and y.y.1.2.
> 
> You mean without an explicit bind()?

You might be able to bind one socket to x.x.1.1 and a second to 10.1.1.1
and x.x.1.1 so that connections to x.x.1.1 are only offered x.x.1.1 and
those to 10.1.1.1 are offered both addresses.

But you can't make the init-ack responses for connections to x.x.1.1
depend on whether the connect came from x.x.1.2 or y.y.1.2.

If the source and destination ports are fixed (as they usually are for M3UA)
you can sit trying to make an outward connection, relying on the init collision
code to work properly. Far from ideal!

	David
