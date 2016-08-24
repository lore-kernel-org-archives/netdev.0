From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 2/2] sctp: not copying duplicate addrs to the assoc's
 bind address list
Date: Wed, 24 Aug 2016 06:38:54 -0400
Message-ID: <20160824103854.GA13154@hmsreliant.think-freely.org>
References: <cover.1471605833.git.lucien.xin@gmail.com>
 <130956b1e880eab780162a795fde156d61d4de0f.1471605833.git.lucien.xin@gmail.com>
 <20160819175007.GB3578@hmsreliant.think-freely.org>
 <CADvbK_do3kQSotq7-PbvoCBBSwOBBdZtx=rR+Q2XX3_bhV4_0w@mail.gmail.com>
 <20160822142538.GA10323@hmsreliant.think-freely.org>
 <CADvbK_ce8EGH5zyvBnOqQX+D5_zj9KTWS=2HbR0BfJ2s-dvWAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34921 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754056AbcHXKjZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:39:25 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_ce8EGH5zyvBnOqQX+D5_zj9KTWS=2HbR0BfJ2s-dvWAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 01:14:27PM +0800, Xin Long wrote:
> >> > Ah, I see what you're doing.  Ok, this makes some sense, at least on the receive
> >> > side, when you get a cookie unpacked and modify the remote peers address list,
> >> > it makes sense to check for duplicates.  On the local side however, I would,
> >> > instead of checking it when the list gets copied, I'd check it when the master
> >> > list gets updated (in the NETDEV_UP event notifier for the local address list,
> >>
> >> I was thinking about to check it in the NETDEV_UP, yes it can make the
> >> master list has no duplicated addresses.  But what if two same addresses
> >> events come, and they come from different NICs (though I can't point  out
> >> the valid use case), then we filter there.
> >>
> > That I think would be a bug in the protocol code.  For the ipv4 case, all
> > addresses are owned by the system and the same addresses added to multiple
> > interfaces should not be allowed.  The same is true of ipv6 case.  The only
> > exception there is a link local address and that should still be unique within
> > the context of an address/dev tuple.
> >
> understand, just sounds a little harsh. :-)
> 
> For now, does it make sense to you to just leave as the master list
> is, and check
> the duplicate address when sctp is really binding them ?
> 
I would think so, yes.
Neil
