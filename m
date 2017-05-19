From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v5 net-next 5/7] net: fix documentation of struct
 scm_timestamping
Date: Fri, 19 May 2017 12:11:18 +0200
Message-ID: <20170519101118.GD21003@localhost>
References: <20170518140738.19617-1-mlichvar@redhat.com>
 <20170518140738.19617-6-mlichvar@redhat.com>
 <CAF=yD-JGUw6pryNV3YevFMxC5=1A62qujAfFO7LjQi2LtsSg4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751598AbdESKLV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 06:11:21 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-JGUw6pryNV3YevFMxC5=1A62qujAfFO7LjQi2LtsSg4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 03:38:30PM -0400, Willem de Bruijn wrote:
> On Thu, May 18, 2017 at 10:07 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > +Note that if the SO_TIMESTAMP or SO_TIMESTAMPNS option is enabled
> > +together with SO_TIMESTAMPING using SOF_TIMESTAMPING_SOFTWARE, a false
> > +software timestamp will be generated in the recvmsg() call and passed
> > +in ts[0] when a real software timestamp is missing.
> 
> With receive software timestamping this is expected behavior? I would make
> explicit that this happens even on tx timestamps.

How about adding ", e.g. when receive timestamping is enabled
between receiving the message and the recvmsg() call, or it is a
message with a hardware transmit timestamp." ?

> > For this reason it
> > +is not recommended to combine SO_TIMESTAMP(NS) with SO_TIMESTAMPING.
> 
> And I'd remove this. The extra timestamp is harmless, and we may be missing
> other reasons why someone would want to enable both on the same socket.

Ok. I'm just concerned people will inadvertently use the timestamp as
a real timestamp and then wonder why SW TX timestamping is so bad. I
have fallen into this trap.

-- 
Miroslav Lichvar
