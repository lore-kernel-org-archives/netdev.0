From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v1 net-next 5/6] net: allow simultaneous SW and HW
 transmit timestamping
Date: Tue, 2 May 2017 11:56:53 +0200
Message-ID: <20170502095653.GB4610@localhost>
References: <20170426145035.25846-1-mlichvar@redhat.com>
 <20170426145035.25846-6-mlichvar@redhat.com>
 <CAF=yD-+GSK491AWQx8=6yd3=-HHwxdWq677ubwdjbV5AXzRbog@mail.gmail.com>
 <20170428085422.GD3401@localhost>
 <CAF=yD-+DYwBbhU0fOMOj4XO+diG4-GLn6Ruh9ZMoXVv5ZS4PgQ@mail.gmail.com>
 <20170428162325.GA2932@localhost>
 <CAF=yD-Ku30zqECeK-68o5Vuk+u4BaU8U3TZR32ZY4mq1y8f6jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60468 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750934AbdEBJ45 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 05:56:57 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-Ku30zqECeK-68o5Vuk+u4BaU8U3TZR32ZY4mq1y8f6jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 28, 2017 at 04:07:29PM -0400, Willem de Bruijn wrote:
> On Fri, Apr 28, 2017 at 12:23 PM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> > On Fri, Apr 28, 2017 at 11:50:28AM -0400, Willem de Bruijn wrote:
> >> A more elegant solution would be to not set SKBTX_IN_PROGRESS
> >> at all if SOF_TIMESTAMPING_OPT_TX_SWHW is set on the socket.
> >> But the patch to do so is not elegant, having to update callsites in many
> >> device drivers.
> >
> > Also, it would change the meaning of the flag as it seems some drivers
> > actually use the SKBTX_IN_PROGRESS flag to check if they expect a
> > timestamp.
> >
> > How about allocating the last bit of tx_flags for SKBTX_SWHW_TSTAMP?
> 
> That is such a scarce resource that I really would prefer to avoid using
> that if we can.

Ok. I think it won't really matter. We should keep in mind that the
reason for adding the OPT_TX_SWHW option was to not break old
applications which enabled both SW and HW TX timestamping, even though
they could get only one timestamp. I think most applications in future
will either enable only SW or HW TX timestamping, or enable both
together with the OPT_TX_SWHW option in order to get a SW timestamp
when HW timestamp was requested but missing.

> >> Otherwise you may indeed have to call skb_tstamp_tx for every packet
> >> that has SKBTX_SW_TSTAMP set, as you do. We can at least move
> >> the skb->sk != NULL check into skb_tx_timestamp in skbuff.h.

There are other callers of skb_tx_timestamp() and it's not obvious to
me they are all safe (i.e. cannot pass skb will sk==NULL), so I think
this should rather be a separate patch if necessary.

I'll resend the series with the other changes you have suggested.

-- 
Miroslav Lichvar
