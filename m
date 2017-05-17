From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v3 net-next 5/7] net: don't make false software transmit
 timestamps
Date: Wed, 17 May 2017 12:27:07 +0200
Message-ID: <20170517102707.GE4156@localhost>
References: <20170516124425.6294-1-mlichvar@redhat.com>
 <20170516124425.6294-6-mlichvar@redhat.com>
 <CAF=yD-+rFQBER8A=P216Bgbtxq+zHgAERoZaGdp=dvo=_otMXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45824 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754061AbdEQK1K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 06:27:10 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-+rFQBER8A=P216Bgbtxq+zHgAERoZaGdp=dvo=_otMXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 06:34:38PM -0400, Willem de Bruijn wrote:
> On Tue, May 16, 2017 at 8:44 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > If software timestamping is enabled by the SO_TIMESTAMP(NS) option
> > when a message without timestamp is already waiting in the queue, the
> > __sock_recv_timestamp() function will read the current time to make a
> > timestamp in order to always have something for the application.
> >
> > However, this applies also to outgoing packets looped back to the error
> > queue when hardware timestamping is enabled by the SO_TIMESTAMPING
> > option.
> 
> This is already the case for sockets that have both software receive
> timestamps and hardware tx timestamps enabled, independent from
> the new option SOF_TIMESTAMPING_OPT_TX_SWHW, right? If so,
> then this behavior must remain.

Even if we consider that it's not actually returning a valid TX
timestamp and it didn't behave as documented ("Only one field is
non-zero at any time")?

On the RX side this timestamp does make some sense as it could be
viewed as a very late timestamp, correctly ordered after the HW
timestamp, but on the TX side the order is reversed and returning a
timestamp later than the actual transmission might break a protocol.

If you don't see it as a bug fix, I think this weird interaction
between the SO_TIMESTAMPING(NS) and SO_TIMESTAMPING options needs to
be documented.

-- 
Miroslav Lichvar
